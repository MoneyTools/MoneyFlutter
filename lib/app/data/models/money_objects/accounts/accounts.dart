// ignore_for_file: unnecessary_this

import 'dart:math';

import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/core/helpers/accumulator.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/accounts/account_types_enum.dart';
import 'package:money/app/data/models/money_objects/investments/investments.dart';
import 'package:money/app/data/models/money_objects/loan_payments/loan_payments.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';

import 'package:money/app/data/storage/data/data.dart';

class Accounts extends MoneyObjects<Account> {
  Accounts() {
    collectionName = 'Accounts';
  }

  @override
  Account instanceFromSqlite(final MyJson row) {
    return Account.fromJson(row);
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
      final Account? account = get(t.fieldAccountId.value);
      if (account != null) {
        if (account.type.value == AccountType.moneyMarket || account.type.value == AccountType.investment) {
          t.getOrCreateInvestment();
        }

        account.count.value++;
        account.balance += t.fieldAmount.value.toDouble();

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

    // Increase the balance of any investment account with the current Stock value
    final investmentAccounts = Data()
        .accounts
        .iterableList()
        .where(
          (account) =>
              account.type.value == AccountType.moneyMarket ||
              account.type.value == AccountType.investment ||
              account.type.value == AccountType.retirement,
        )
        .toList();

    AccumulatorList<String, Investment> groupBySymbol = AccumulatorList<String, Investment>();

    for (final account in investmentAccounts) {
      groupAccountStockSymbols(account, groupBySymbol);
    }

    // apply the investment running banalnce amount
    groupBySymbol.values.forEach((keyAccountAndSymbol, valuesInvestments) {
      double totalAdjustedShareForThisStockInThisAccount =
          Investments.applyHoldingSharesAjustedForSplits(valuesInvestments.toList());
      final tokens = keyAccountAndSymbol.split('|');
      final accountId = tokens[0];
      final symbol = tokens[1];
      final account = Data().accounts.get(int.parse(accountId));
      if (account != null) {
        final security = Data().securities.getBySymbol(symbol);
        if (security != null) {
          account.stockHoldingEstimation.value
              .setAmount(totalAdjustedShareForThisStockInThisAccount * security.fieldLastPrice.value.toDouble());
          if (account.stockHoldingEstimation.value.toDouble() != 0) {
            account.balance += account.stockHoldingEstimation.value.toDouble();
          }
        }
      }
    });

    // Loans
    final accountLoans =
        Data().accounts.iterableList().where((account) => account.type.value == AccountType.loan).toList();
    for (final account in accountLoans) {
      final LoanPayment? latestPayment = getAccountLoanPayments(account).lastOrNull;
      if (latestPayment != null) {
        account.updatedOn.value = latestPayment.fieldDate.value;
        account.balance = latestPayment.fieldBalance.value.toDouble() * -1;
      }
    }

    // Credit Card "Paid On" date
    // attempt to match Statement balance to a payment
    for (final Account account in iterableList().where((a) => a.type.value == AccountType.credit)) {
      _updateCreditCardPaidOn(account);
    }
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
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

  bool activeBankAccount(final Account account) {
    return account.isActiveBankAccount();
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
    account.fieldName.value = nextAvailableName;
    account.isOpen = true;

    Data().accounts.appendNewMoneyObject(account, fireNotification: false);
    return account;
  }

  bool compareDoubles(double a, double b, int precision) {
    final threshold = pow(10, -precision);
    return (a - b).abs() < threshold;
  }

  /// Find a transaction that has a date in the futurebut not more than 2 months and has inverse amount
  Transaction? findBackwardInTimeForTransactionBalanceThatMatchThisAmount(
    final List<Transaction> transactionForAccountSortedByDateAscending,
    final indexStartingFrom,
    final DateTime validDateInThePast,
    final double amountToMatch,
  ) {
    for (int i = indexStartingFrom; i >= 0; i--) {
      final Transaction t = transactionForAccountSortedByDateAscending[i];

      if (t.dateTime.value!.isBefore(validDateInThePast)) {
        return null; // out of range break early
      }

      if (compareDoubles(t.balance, amountToMatch, 2)) {
        return t;
      }
    }

    return null;
  }

  Account? findByIdAndType(
    final String accountId,
    final AccountType? accountType,
  ) {
    return iterableList().firstWhereOrNull((final Account account) {
      return account.fieldAccountId.value == accountId && (accountType == null || account.type.value == accountType);
    });
  }

  Account? getByName(final String name) {
    return iterableList().firstWhereOrNull((final Account item) {
      return stringCompareIgnoreCasing2(item.fieldName.value, name) == 0;
    });
  }

  List<Account> getListSorted() {
    final list = iterableList()
        .where(
          (account) =>
              account.isMatchingUserChoiceIncludingClosedAccount && account.type.value != AccountType.categoryFund,
        )
        .toList();
    list.sort((a, b) => sortByString(a.fieldName.value, b.fieldName.value, true));
    return list;
  }

  Account getMostRecentlySelectedAccount() {
    final int lastSelectionId = PreferenceController.to.getInt(getViewPreferenceIdAccountLastSelected(), -1);
    if (lastSelectionId != -1) {
      final Account? accountExist = get(lastSelectionId);
      if (accountExist != null) {
        return accountExist;
      }
    }

    return firstItem()!;
  }

  String getNameFromId(final num id) {
    final Account? account = get(id);
    if (account == null) {
      return id.toString();
    }
    return account.fieldName.value;
  }

  List<Account> getOpenAccounts() {
    return iterableList().where((final Account account) => account.isOpen).toList();
  }

  List<Account> getOpenRealAccounts() {
    return iterableList()
        .where(
          (final Account account) => !account.isFakeAccount() && account.isOpen,
        )
        .toList();
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

  Iterable<Transaction> getTransactions(final Account account) {
    return Data().transactions.iterableList().where((t) => t.fieldAccountId.value == account.uniqueId);
  }

  String getViewPreferenceIdAccountLastSelected() {
    return ViewId.viewAccounts.getViewPreferenceId(settingKeySelectedListItemId);
  }

  static void groupAccountStockSymbols(Account account, AccumulatorList<String, Investment> groupBySymbol) {
    final investments =
        Data().investments.iterableList().where((i) => i.transactionInstance!.fieldAccountId.value == account.uniqueId);

    for (final Investment investment in investments) {
      final Security? security = Data().securities.get(investment.fieldSecurity.value);
      if (security != null) {
        final stockSymbol = security.fieldSymbol.value;
        groupBySymbol.cumulate('${account.uniqueId}|$stockSymbol', investment);
      }
    }
  }

  bool removeAccount(Account a, [bool forceRemoveAfterSave = false]) {
    if (a.isInserted || forceRemoveAfterSave) {
      if (this.containsKey(a.uniqueId)) {
        deleteItem(a);
      }
    }

    // Fix up any transfers that are pointing to this account.
    Iterable<Transaction> view = Data().transactions.findTransfersToAccount(a);
    if (view.isNotEmpty) {
      for (Transaction u in view) {
        Data().clearTransferToAccount(u, a);
      }
    }

    view = getTransactions(a);

    for (Transaction t in view) {
      Data().removeTransaction(t);
    }
    return true;
  }

  void setMostRecentUsedAccount(Account account) {
    PreferenceController.to.setInt(getViewPreferenceIdAccountLastSelected(), account.id.value);
  }

  void _updateCreditCardPaidOn(final Account account) {
    final transactionForAccountSortedByDateAscending =
        Data().transactions.iterableList().where((t) => t.fieldAccountId.value == account.uniqueId).toList();
    // sort date as string to match the ListView sorting logic
    transactionForAccountSortedByDateAscending.sort((a, b) => Transaction.sortByDateTime(a, b, true));

    double runningBalanceForThisAccount = 0;

    for (final t in transactionForAccountSortedByDateAscending) {
      runningBalanceForThisAccount += t.fieldAmount.value.toDouble();
      t.balance = runningBalanceForThisAccount;
      t.paidOn.value = '';
    }

    final int length = transactionForAccountSortedByDateAscending.length - 1;

    for (int i = length; i >= 0; i--) {
      final Transaction t = transactionForAccountSortedByDateAscending[i];
      if (t.fieldAmount.value.toDouble() > 0) {
        // a paymenent or reibursement was made

        final DateTime maxDateToLookAt = t.dateTime.value!.subtract(const Duration(days: 60));
        final transactionWithMatchingBalance = findBackwardInTimeForTransactionBalanceThatMatchThisAmount(
          transactionForAccountSortedByDateAscending,
          i - 1,
          maxDateToLookAt,
          -t.fieldAmount.value.toDouble(),
        );

        if (transactionWithMatchingBalance == null) {
          // t.paidOn.value = doubleToCurrency(statementBalance, '');
        } else {
          transactionWithMatchingBalance.paidOn.value = '${t.dateTimeAsText} ⤵';
          t.paidOn.value = '${transactionWithMatchingBalance.dateTimeAsText} ⤴${t.paidOn.value.isNotEmpty ? '⤵' : ''}';
        }
      }
    }
  }
}
