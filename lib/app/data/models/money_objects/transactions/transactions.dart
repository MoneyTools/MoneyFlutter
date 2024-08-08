// ignore_for_file: prefer_conditional_assignment

import 'dart:math';

import 'package:money/app/core/helpers/accumulator.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/ranges.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/models/money_objects/transfers/transfer.dart';
import 'package:money/app/data/storage/data/data.dart';

export 'package:money/app/data/models/money_objects/transactions/transaction.dart';

part 'transactions_csv.dart';

class Transactions extends MoneyObjects<Transaction> {
  Transactions() {
    collectionName = 'Transactions';
  }

  DateRange dateRangeActiveAccount = DateRange();
  DateRange dateRangeIncludingClosedAccount = DateRange();
  double runningBalance = 0.00;

  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();

    runningBalance = 0.00;

    for (final MyJson row in rows) {
      final Transaction t = Transaction.fromJSon(row, runningBalance);
      runningBalance += t.balance;
      appendMoneyObject(t);
    }
  }

  /// Now that everything is loaded, adjust relation between MoneyObjects
  @override
  void onAllDataLoaded() {
    // Pre computer possible category matching for Transaction that have no associated categories
    // Stopwatch watchAll = Stopwatch()..start();

    // Stopwatch watchInit = Stopwatch()..start();
    MapAccumulatorSet<int, String, int> accountsToPayeeNameToCategories = MapAccumulatorSet<int, String, int>();

    final transactionsWithCategories = getListFlattenSplits();
    for (var t in transactionsWithCategories) {
      if (t.fieldCategoryId.value != -1) {
        accountsToPayeeNameToCategories.cumulate(
          t.fieldAccountId.value,
          t.getPayeeOrTransferCaption(),
          t.fieldCategoryId.value,
        );
      }
    }

    // watchInit.stop();
    // debugInfo('getListFlattenSplits: ${watchInit.elapsedMilliseconds} ms');

    // Stopwatch watchFind = Stopwatch();
    dateRangeActiveAccount.clear();
    dateRangeIncludingClosedAccount.clear();

    for (final Transaction transactionSource in iterableList()) {
      // Pre computer possible category matching for Transaction that have no associated categories
      if (transactionSource.fieldCategoryId.value == -1) {
        // watchFind.start();
        final Set<int> setOfPossibleCategoryId = accountsToPayeeNameToCategories.find(
          transactionSource.fieldAccountId.value,
          transactionSource.getPayeeOrTransferCaption(),
        );
        transactionSource.possibleMatchingCategoryId =
            setOfPossibleCategoryId.isEmpty ? -1 : setOfPossibleCategoryId.first;
        // watchFind.stop();
      }

      // Computer date range of all transactions
      dateRangeIncludingClosedAccount.inflate(transactionSource.fieldDateTime.value);
      if (transactionSource.instanceOfAccount?.isOpen == true) {
        dateRangeActiveAccount.inflate(transactionSource.fieldDateTime.value!);
      }

      // Resolve the Transfers
      final int transferId = transactionSource.fieldTransfer.value;
      transactionSource.instanceOfTransfer = null;

      if (transactionSource.fieldTransferSplit.value > 0) {
        // deal with transfer of split
        // Split transfer
        // if (transactionSource.transferSplit.value != -1) {
        //   final Split? s = Data().splits.get(transactionSource.transferSplit.value);
        //   if (s == null) {
        //     debugInfo('Transaction contains a split marked as a transfer, but other side of transfer was not found');
        //     continue;
        //   }
        //
        //   if (transactionSource.transferInstance == null) {
        //     transactionSource.transferInstance =
        //         Transfer(id: transferId, source: transactionSource, related: transactionRelated, relatedSplit: s);
        //     continue;
        //   }
        // debugInfo('Already have a transfer for this split');
        // }
        continue;
      }

      // Simple Transfer
      if (transferId == -1) {
        if (transactionSource.instanceOfTransfer == null) {
          // this is correct
        } else {
          // this needs to be cleared
          // TODO - should the other side transaction be cleared too?
          transactionSource.instanceOfTransfer = null;
        }
      } else {
        // hook up the transfer relation
        final Transaction? transactionRelated = get(transferId);

        // check for error
        if (transactionRelated == null) {
          logger.e(
            'Transaction.transferID of ${transactionSource.uniqueId} missing related transaction id $transferId',
          );
          continue;
        }

        // hydrate the Transfer
        if (transactionSource.fieldTransferSplit.value == -1) {
          // Normal direct transfer

          if (transactionSource.instanceOfTransfer == null) {
            // cache the transfer
            transactionSource.instanceOfTransfer = Transfer(
              id: 0,
              source: transactionSource,
              related: transactionRelated,
              isOrphan: false,
            );
          }

          if (transactionRelated.instanceOfTransfer == null) {
            // cache the transfer
            transactionRelated.instanceOfTransfer = Transfer(
              id: 0,
              source: transactionRelated,
              related: transactionSource,
              isOrphan: false,
            );
          }
          continue;
        }
      }
    }

    // make sure that we have valid min max dates
    dateRangeIncludingClosedAccount.ensureNoNullDates();
    dateRangeActiveAccount.ensureNoNullDates();
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }

  void checkTransfers(Set<Transaction> dangling, List<Account> deletedaccounts) {
    for (Transaction t in iterableList()) {
      t.checkTransfers(dangling, deletedaccounts);
    }
  }

  /// match amount and date YYYY,MM,DD, optionally restric to a specific account by passing -1
  Transaction? findExistingTransaction({
    required final int accountId,
    required final DateRange dateRange,
    required final double amount,
  }) {
    return iterableList(includeDeleted: true).firstWhereOrNull((transaction) {
      if ((accountId == -1 || transaction.fieldAccountId.value == accountId) &&
          transaction.fieldAmount.value.toDouble() == amount &&
          dateRange.isBetweenEqual(transaction.fieldDateTime.value)) {
        return true;
      }

      return false;
    });
  }

  int findPossibleMatchingCategoryId(final Transaction t, List<Transaction> transactionWithCategories) {
    final transactionMatchingAccountPayeeAndHasCategory = transactionWithCategories.firstWhereOrNull(
      (item) =>
          item.fieldAccountId.value == t.fieldAccountId.value &&
          item.getPayeeOrTransferCaption() == t.getPayeeOrTransferCaption(),
    );
    if (transactionMatchingAccountPayeeAndHasCategory != null) {
      return transactionMatchingAccountPayeeAndHasCategory.fieldCategoryId.value;
    }
    return -1;
  }

  Iterable<Transaction> findTransfersToAccount(final Account a) {
    List<Transaction> view = [];
    for (Transaction t in iterableList()) {
      if (t.isDeleted) {
        continue;
      }

      if (t.containsTransferTo(a)) {
        view.add(t);
      }
    }
    // view.sort(SortByDate);
    return view;
  }

  static List<Transaction> flatTransactions(
    final Iterable<Transaction> transactions,
  ) {
    List<Transaction> flatList = [];
    for (final t in transactions) {
      if (t.isSplit) {
        for (final s in t.splits) {
          final fakeTransaction = Transaction(date: t.fieldDateTime.value, status: t.fieldStatus.value);
          fakeTransaction.fieldCategoryId.value = s.fieldCategoryId.value;
          fakeTransaction.fieldAmount.value = s.fieldAmount.value;
          flatList.add(fakeTransaction);
        }
      } else {
        flatList.add(t);
      }
    }
    return flatList;
  }

  List<Transaction> getAllTransactionsByDate() {
    final List<Transaction> theListOfAllTransactionIncludingHiddenOne = iterableList().toList(growable: false);
    theListOfAllTransactionIncludingHiddenOne.sort(
      (final Transaction a, final Transaction b) => sortByDate(a.fieldDateTime.value, b.fieldDateTime.value, true),
    );
    return theListOfAllTransactionIncludingHiddenOne;
  }

  List<Transaction> getListFlattenSplits({
    final bool Function(Transaction)? whereClause,
  }) {
    List<Transaction> flattenList = [];
    for (final t in iterableList()) {
      if (whereClause == null || whereClause(t)) {
        if (t.fieldCategoryId.value == Data().categories.splitCategoryId()) {
          for (final s in t.splits) {
            final fakeT = Transaction(date: t.fieldDateTime.value, status: t.fieldStatus.value)
              ..fieldAccountId.value = t.fieldAccountId.value
              ..fieldPayee.value = s.fieldPayeeId.value == -1 ? t.fieldPayee.value : s.fieldPayeeId.value
              ..fieldCategoryId.value = s.fieldCategoryId.value
              ..fieldMemo.value = s.fieldMemo.value
              ..fieldAmount.value = s.fieldAmount.value;

            flattenList.add(fakeT);
          }
        } else {
          flattenList.add(t);
        }
      }
    }
    return flattenList;
  }

  int getNextTransactionId() {
    int maxIdFound = -1;
    for (final item in iterableList(includeDeleted: true)) {
      maxIdFound = max(maxIdFound, item.fieldId.value);
    }
    return maxIdFound + 1;
  }

  Iterable<Transaction> transactionInYearRange({
    required final int minYear,
    required final int maxYear,
    required final bool? incomesOrExpenses,
  }) {
    return iterableList(includeDeleted: true).where(
      (element) =>
          isBetweenOrEqual(element.fieldDateTime.value!.year, minYear, maxYear) &&
          ((incomesOrExpenses == null ||
              (incomesOrExpenses == true && element.fieldAmount.value.toDouble() > 0) ||
              (incomesOrExpenses == false && element.fieldAmount.value.toDouble() < 0))),
    );
  }

  static List<Pair<int, double>> transactionSumByTime(
    List<Transaction> transactions,
  ) {
    List<Pair<int, double>> timeAndAmounts = [];
    for (final t in transactions) {
      int oneDaySlot = t.fieldDateTime.value!.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
      timeAndAmounts.add(Pair<int, double>(oneDaySlot, t.fieldAmount.value.toDouble()));
    }
    // sort by date time
    timeAndAmounts.sort((a, b) => a.first.compareTo(b.first));
    return timeAndAmounts;
  }
}
