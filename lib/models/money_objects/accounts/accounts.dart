import 'dart:math';

import 'package:money/helpers/list_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/investments/cost_basis.dart';
import 'package:money/models/money_objects/investments/security_purchase.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';

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
      // ignore: always_specify_types
      {
        'Id': -1,
        'AccountId': 'BankAccountIdForTesting',
        'Name': 'U.S. Bank',
        'Type': AccountType.savings.index,
        'Currency': 'USD',
      },
      // ignore: always_specify_types
      {'Id': -1, 'Name': 'Bank Of America', 'Type': AccountType.checking.index, 'Currency': 'USD'},
      // ignore: always_specify_types
      {'Id': -1, 'Name': 'KeyBank', 'Type': AccountType.moneyMarket.index, 'Currency': 'USD'},
      // ignore: always_specify_types
      {'Id': -1, 'Name': 'Mattress', 'Type': AccountType.cash.index, 'Currency': 'USD'},
      // ignore: always_specify_types
      {'Id': -1, 'Name': 'Revolut UK', 'Type': AccountType.credit.index, 'Currency': 'GBP'},
      // ignore: always_specify_types
      {'Id': -1, 'Name': 'Fidelity', 'Type': AccountType.investment.index, 'Currency': 'USD'},
      // ignore: always_specify_types
      {'Id': -1, 'Name': 'Bank of Japan', 'Type': AccountType.retirement.index, 'Currency': 'JPY'},
      // ignore: always_specify_types
      {'Id': -1, 'Name': 'James Bonds', 'Type': AccountType.asset.index, 'Currency': 'GBP'},
      // ignore: always_specify_types
      {'Id': -1, 'Name': 'KickStarter', 'Type': AccountType.loan.index, 'Currency': 'CAD'},
      // ignore: always_specify_types
      {'Id': -1, 'Name': 'Home Remodel', 'Type': AccountType.creditLine.index, 'Currency': 'USD'},
    ];
    for (final MyJson demoAccount in demoAccounts) {
      appendNewMoneyObject(Account.fromJson(demoAccount));
    }
  }

  @override
  void onAllDataLoaded() {
    // reset balances
    for (final Account account in iterableList()) {
      account.count.value = 0;
      account.balance.value = account.openingBalance.value;
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
    for (final Transaction t
        in Data().transactions.iterableList().sorted((a, b) => sortByDate(a.dateTime.value, b.dateTime.value))) {
      final Account? account = get(t.accountId.value);
      if (account != null) {
        if (account.type.value == AccountType.moneyMarket || account.type.value == AccountType.investment) {
          t.getOrCreateInvestment();
        }

        account.count.value++;
        account.balance.value += t.amount.value;

        final int yearOfTheTransaction = t.dateTime.value!.year;

        // Min Balance of the year
        final double currentMinBalanceValue =
            account.minBalancePerYears[yearOfTheTransaction] ?? IntValues.maxSigned(32).toDouble();
        account.minBalancePerYears[yearOfTheTransaction] = min(currentMinBalanceValue, account.balance.value);

        // Max Balance of the year
        final double currentMaxBalanceValue =
            account.maxBalancePerYears[yearOfTheTransaction] ?? IntValues.minSigned(32).toDouble();
        account.maxBalancePerYears[yearOfTheTransaction] = max(currentMaxBalanceValue, account.balance.value);
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
      // debugLog('${account.name.value} BEFORE: ${account.balance.value}');

      for (SecurityPurchase sp in calculator.getHolding(account).getHoldings()) {
        account.balance.value += sp.latestMarketValue!;
      }

      // debugLog('${account.name.value} AFTER: ${account.balance.value}');
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

    Data().accounts.appendNewMoneyObject(account);
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
    final AccountType accountType,
  ) {
    return iterableList().firstWhereOrNull((final Account item) {
      return item.accountId.value == accountId && item.type.value == accountType;
    });
  }

  Account? getByName(final String name) {
    return iterableList().firstWhereOrNull((final Account item) {
      return stringCompareIgnoreCasing2(item.name.value, name) == 0;
    });
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }

  List<Account> getListSorted() {
    final list = iterableList().toList();
    list.sort((a, b) => sortByString(a.name.value, b.name.value, true));
    return list;
  }
}

Account getLastUsedOrFirstAccount() {
  Account? account = Settings().mostRecentlySelectedAccount;
  account ??= Data().accounts.firstItem();
  return account!;
}
