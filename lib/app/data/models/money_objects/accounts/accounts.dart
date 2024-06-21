import 'dart:math';

import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/accounts/account_types_enum.dart';
import 'package:money/app/data/models/money_objects/investments/cost_basis.dart';
import 'package:money/app/data/models/money_objects/investments/security_purchase.dart';
import 'package:money/app/data/models/money_objects/loan_payments/loan_payments.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/preferences_helper.dart';

class Accounts extends MoneyObjects<Account> {
  Accounts() {
    collectionName = 'Accounts';
  }

  @override
  Account instanceFromSqlite(final MyJson row) {
    return Account.fromJson(row);
  }

  @override
  void loadDemoData() {
    clear();
    final List<MyJson> demoAccounts = <MyJson>[
      {
        'Id': -1,
        'AccountId': 'BankAccountIdForTesting',
        'Name': 'U.S. Bank',
        'Type': AccountType.savings.index,
        'Currency': 'USD',
      },
      {
        'Id': -1,
        'Name': 'Bank Of America',
        'AccountId': '0001',
        'Type': AccountType.checking.index,
        'Currency': 'USD',
      },
      {
        'Id': -1,
        'Name': 'KeyBank',
        'AccountId': '0002',
        'Type': AccountType.moneyMarket.index,
        'Currency': 'USD',
      },
      {
        'Id': -1,
        'Name': 'Mattress',
        'AccountId': '0003',
        'Type': AccountType.cash.index,
        'Currency': 'USD',
      },
      {
        'Id': -1,
        'Name': 'Revolut UK',
        'AccountId': '0005',
        'Type': AccountType.credit.index,
        'Currency': 'GBP',
      },
      {
        'Id': -1,
        'Name': 'Fidelity',
        'AccountId': '0006',
        'Type': AccountType.investment.index,
        'Currency': 'USD',
      },
      {
        'Id': -1,
        'Name': 'Bank of Japan',
        'AccountId': '11111',
        'Type': AccountType.retirement.index,
        'Currency': 'JPY'
      },
      {
        'Id': -1,
        'Name': 'James Bonds',
        'AccountId': '007',
        'Type': AccountType.asset.index,
        'Currency': 'GBP',
      },
      {
        'Id': -1,
        'Name': 'KickStarter',
        'AccountId': 'K000',
        'Type': AccountType.loan.index,
        'Currency': 'CAD',
      },
      {
        'Id': -1,
        'Name': 'Home Remodel',
        'AccountId': 'H0001',
        'Type': AccountType.creditLine.index,
        'Currency': 'USD',
      },
    ];

    for (final MyJson demoAccount in demoAccounts) {
      appendNewMoneyObject(Account.fromJson(demoAccount), fireNotification: false);
    }
  }

  @override
  void onAllDataLoaded() {
    // reset balances
    for (final Account account in iterableList()) {
      account.count.value = 0;
      account.balance = account.openingBalance.value;
      account.minBalancePerYears.clear();
      account.maxBalancePerYears.clear();

      // TODO when we deal with downloading online
      // account.onlineAccountInstance = Data().onlineAccounts.get(this.onlineAccountId);

      // TODO as seen in MyMoney.net
      // if (!string.IsNullOrEmpty(this.categoryForPrincipalName))
      // {
      //   this.CategoryForPrincipal = myMoney.Categories.GetOrCreateCategory(this.categoryForPrincipalName, CategoryType.Expense);
      //   this.categoryForPrincipalName = null;
      // }
      // if (!string.IsNullOrEmpty(this.categoryForInterestName))
      // {
      //   this.categoryForInterest = myMoney.Categories.GetOrCreateCategory(this.categoryForInterestName, CategoryType.Expense);
      //   this.categoryForInterestName = null;
      // }
    }

    // Cumulate
    final transactionsSortedByDate =
        Data().transactions.iterableList().sorted((a, b) => sortByDate(a.dateTime.value, b.dateTime.value));

    for (final Transaction t in transactionsSortedByDate) {
      final Account? account = get(t.accountId.value);
      if (account != null) {
        if (account.type.value == AccountType.moneyMarket || account.type.value == AccountType.investment) {
          t.getOrCreateInvestment();
        }

        account.count.value++;
        account.balance += t.amount.value.toDouble();

        final int yearOfTheTransaction = t.dateTime.value!.year;

        // Min Balance of the year
        final double currentMinBalanceValue =
            account.minBalancePerYears[yearOfTheTransaction] ?? IntValues.maxSigned(32).toDouble();
        account.minBalancePerYears[yearOfTheTransaction] = min(currentMinBalanceValue, account.balance);

        // Max Balance of the year
        final double currentMaxBalanceValue =
            account.maxBalancePerYears[yearOfTheTransaction] ?? IntValues.minSigned(32).toDouble();
        account.maxBalancePerYears[yearOfTheTransaction] = max(currentMaxBalanceValue, account.balance);

        // keep track of the most recent record transaction for the account
        if (t.dateTime.value != null) {
          if (account.updatedOn.value == null || account.updatedOn.value!.compareTo(t.dateTime.value!) < 0) {
            account.updatedOn.value = t.dateTime.value;
          }
        }
      }
    }

    final investmentAccounts = Data()
        .accounts
        .iterableList()
        .where((account) =>
            account.type.value == AccountType.moneyMarket ||
            account.type.value == AccountType.investment ||
            account.type.value == AccountType.retirement)
        .toList();

    CostBasisCalculator calculator = CostBasisCalculator(DateTime.now());
    for (final account in investmentAccounts) {
      for (SecurityPurchase sp in calculator.getHolding(account).getHoldings()) {
        account.balance += sp.latestMarketValue!;
      }
    }

    // Loans
    final accountLoans =
        Data().accounts.iterableList().where((account) => account.type.value == AccountType.loan).toList();
    for (final account in accountLoans) {
      final LoanPayment? latestPayment = getAccountLoanPayments(account).lastOrNull;
      if (latestPayment != null) {
        account.updatedOn.value = latestPayment.date.value;
        account.balance = latestPayment.balance.value.toDouble();
      }
    }
  }

  Account addNewAccount(final String accountName) {
    // find next available name
    String nextAvailableName = accountName;
    int next = 1;
    while ((getByName(nextAvailableName) != null)) {
      // already taken
      nextAvailableName = '$accountName $next';
      // the the next one
      next++;
    }

    // add a new Account
    final account = Account();
    account.name.value = nextAvailableName;
    account.isOpen = true;

    Data().accounts.appendNewMoneyObject(account, fireNotification: false);
    return account;
  }

  List<Account> getOpenAccounts() {
    return iterableList().where((final Account account) => account.isOpen).toList();
  }

  List<Account> getOpenRealAccounts() {
    return iterableList().where((final Account account) => !account.isFakeAccount() && account.isOpen).toList();
  }

  bool activeBankAccount(final Account account) {
    return account.isActiveBankAccount();
  }

  List<Account> activeAccount(
    final List<AccountType> types, {
    final bool? isActive = true,
  }) {
    return iterableList().where((final Account item) {
      if (!item.matchType(types)) {
        return false;
      }
      if (isActive == null) {
        return true;
      }
      return item.isOpen == isActive;
    }).toList();
  }

  String getNameFromId(final num id) {
    final Account? account = get(id);
    if (account == null) {
      return id.toString();
    }
    return account.name.value;
  }

  Account? findByIdAndType(
    final String accountId,
    final AccountType? accountType,
  ) {
    return iterableList().firstWhereOrNull((final Account account) {
      return account.accountId.value == accountId && (accountType == null || account.type.value == accountType);
    });
  }

  Account? getByName(final String name) {
    return iterableList().firstWhereOrNull((final Account item) {
      return stringCompareIgnoreCasing2(item.name.value, name) == 0;
    });
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }

  List<Account> getListSorted() {
    final list = iterableList()
        .where((account) =>
            account.isMatchingUserChoiceIncludingClosedAccount && account.type.value != AccountType.categoryFund)
        .toList();
    list.sort((a, b) => sortByString(a.name.value, b.name.value, true));
    return list;
  }

  String getViewPreferenceIdAccountLastSelected() {
    return ViewId.viewAccounts.getViewPreferenceId(settingKeySelectedListItemId);
  }

  Account getMostRecentlySelectedAccount() {
    final int? lastSelectionId = PreferencesHelper().getInt(getViewPreferenceIdAccountLastSelected());
    if (lastSelectionId != null) {
      final Account? accountExist = get(lastSelectionId);
      if (accountExist != null) {
        return accountExist;
      }
    }

    return firstItem()!;
  }

  void setMostRecentUsedAccount(Account account) {
    PreferencesHelper().setInt(getViewPreferenceIdAccountLastSelected(), account.id.value);
  }

  double getSumOfAccountBalances() {
    double sum = 0.00;

    for (final account in iterableList()) {
      if (account.isMatchingUserChoiceIncludingClosedAccount) {
        sum += account.balanceNormalized.getValueForDisplay(account).toDouble();
      }
    }
    return sum;
  }
}
