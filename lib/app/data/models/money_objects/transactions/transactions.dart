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
      if (t.categoryId.value != -1) {
        accountsToPayeeNameToCategories.cumulate(t.accountId.value, t.getPayeeOrTransferCaption(), t.categoryId.value);
      }
    }

    // watchInit.stop();
    // debugLog('getListFlattenSplits: ${watchInit.elapsedMilliseconds} ms');

    // Stopwatch watchFind = Stopwatch();
    dateRangeActiveAccount.clear();
    dateRangeIncludingClosedAccount.clear();

    for (final Transaction transactionSource in iterableList()) {
      // Pre computer possible category matching for Transaction that have no associated categories
      if (transactionSource.categoryId.value == -1) {
        // watchFind.start();
        final Set<int> setOfPossibleCategoryId = accountsToPayeeNameToCategories.find(
          transactionSource.accountId.value,
          transactionSource.getPayeeOrTransferCaption(),
        );
        transactionSource.possibleMatchingCategoryId =
            setOfPossibleCategoryId.isEmpty ? -1 : setOfPossibleCategoryId.first;
        // watchFind.stop();
      }

      // Computer date range of all transactions
      dateRangeIncludingClosedAccount.inflate(transactionSource.dateTime.value);
      if (transactionSource.accountInstance?.isOpen == true) {
        dateRangeActiveAccount.inflate(transactionSource.dateTime.value!);
      }

      // Resolve the Transfers
      final int transferId = transactionSource.transfer.value;
      transactionSource.transferInstance = null;

      if (transactionSource.transferSplit.value > 0) {
        // deal with transfer of split
        // Split transfer
        // if (transactionSource.transferSplit.value != -1) {
        //   final Split? s = Data().splits.get(transactionSource.transferSplit.value);
        //   if (s == null) {
        //     debugLog('Transaction contains a split marked as a transfer, but other side of transfer was not found');
        //     continue;
        //   }
        //
        //   if (transactionSource.transferInstance == null) {
        //     transactionSource.transferInstance =
        //         Transfer(id: transferId, source: transactionSource, related: transactionRelated, relatedSplit: s);
        //     continue;
        //   }
        // debugLog('Already have a transfer for this split');
        // }
        continue;
      }

      // Simple Transfer
      if (transferId == -1) {
        if (transactionSource.transferInstance == null) {
          // this is correct
        } else {
          // this needs to be cleared
          // TODO - should the other side transaction be cleared too?
          transactionSource.transferInstance = null;
        }
      } else {
        // hook up the transfer relation
        final Transaction? transactionRelated = get(transferId);

        // check for error
        if (transactionRelated == null) {
          debugLog(
            'Transaction.transferID of ${transactionSource.uniqueId} missing related transaction id $transferId',
          );
          continue;
        }

        // hydrate the Transfer
        if (transactionSource.transferSplit.value == -1) {
          // Normal direct transfer

          if (transactionSource.transferInstance == null) {
            // cache the transfer
            transactionSource.transferInstance = Transfer(
              id: 0,
              source: transactionSource,
              related: transactionRelated,
              isOrphan: false,
            );
          }

          if (transactionRelated.transferInstance == null) {
            // cache the transfer
            transactionRelated.transferInstance = Transfer(
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

    // debugLog('DONE-----: ${watchAll.elapsedMilliseconds} ms');
    // debugLog('Find-----: ${watchFind.elapsedMilliseconds} ms');
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
      if ((accountId == -1 || transaction.accountId.value == accountId) &&
          transaction.amount.value.toDouble() == amount &&
          dateRange.isBetweenEqual(transaction.dateTime.value)) {
        return true;
      }

      return false;
    });
  }

  int findPossibleMatchingCategoryId(final Transaction t, List<Transaction> transactionWithCategories) {
    final transactionMatchingAccountPayeeAndHasCategory = transactionWithCategories.firstWhereOrNull(
      (item) =>
          item.accountId.value == t.accountId.value &&
          item.getPayeeOrTransferCaption() == t.getPayeeOrTransferCaption(),
    );
    if (transactionMatchingAccountPayeeAndHasCategory != null) {
      return transactionMatchingAccountPayeeAndHasCategory.categoryId.value;
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
          final fakeTransaction = Transaction(date: t.dateTime.value, status: t.status.value);
          fakeTransaction.categoryId.value = s.categoryId.value;
          fakeTransaction.amount.value = s.amount.value;
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
      (final Transaction a, final Transaction b) => sortByDate(a.dateTime.value, b.dateTime.value, true),
    );
    return theListOfAllTransactionIncludingHiddenOne;
  }

  List<Transaction> getListFlattenSplits({
    final bool Function(Transaction)? whereClause,
  }) {
    List<Transaction> flattenList = [];
    for (final t in iterableList()) {
      if (whereClause == null || whereClause(t)) {
        if (t.categoryId.value == Data().categories.splitCategoryId()) {
          for (final s in t.splits) {
            final fakeT = Transaction(date: t.dateTime.value, status: t.status.value)
              ..accountId.value = t.accountId.value
              ..payee.value = s.payeeId.value == -1 ? t.payee.value : s.payeeId.value
              ..categoryId.value = s.categoryId.value
              ..memo.value = s.memo.value
              ..amount.value = s.amount.value;

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
      maxIdFound = max(maxIdFound, item.id.value);
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
          isBetweenOrEqual(element.dateTime.value!.year, minYear, maxYear) &&
          ((incomesOrExpenses == null ||
              (incomesOrExpenses == true && element.amount.value.toDouble() > 0) ||
              (incomesOrExpenses == false && element.amount.value.toDouble() < 0))),
    );
  }

  static List<Pair<int, double>> transactionSumByTime(
    List<Transaction> transactions,
  ) {
    List<Pair<int, double>> timeAndAmounts = [];
    for (final t in transactions) {
      int oneDaySlot = t.dateTime.value!.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
      timeAndAmounts.add(Pair<int, double>(oneDaySlot, t.amount.value.toDouble()));
    }
    // sort by date time
    timeAndAmounts.sort((a, b) => a.first.compareTo(b.first));
    return timeAndAmounts;
  }
}
