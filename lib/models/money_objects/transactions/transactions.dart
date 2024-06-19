import 'dart:math';

import 'package:money/helpers/list_helper.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/accounts/account_types_enum.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/models/money_objects/transfers/transfer.dart';
import 'package:money/storage/data/data.dart';

export 'package:money/models/money_objects/transactions/transaction.dart';

part 'transactions_csv.dart';

part 'transactions_demo.dart';

class Transactions extends MoneyObjects<Transaction> {
  Transactions() {
    collectionName = 'Transactions';
  }

  List<Transaction> getListFlattenSplits({final bool Function(Transaction)? whereClause}) {
    List<Transaction> flattenList = [];
    for (final t in iterableList()) {
      if (whereClause == null || whereClause(t)) {
        if (t.categoryId.value == Data().categories.splitCategoryId()) {
          for (final s in t.splits) {
            final fakeT = Transaction(status: t.status.value)
              ..dateTime.value = t.dateTime.value
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

  Iterable<Transaction> transactionInYearRange({
    required final int minYear,
    required final int maxYear,
    required final bool? incomesOrExpenses,
  }) {
    return iterableList(includeDeleted: true).where((element) =>
        isBetweenOrEqual(element.dateTime.value!.year, minYear, maxYear) &&
        ((incomesOrExpenses == null ||
            (incomesOrExpenses == true && element.amount.value.toDouble() > 0) ||
            (incomesOrExpenses == false && element.amount.value.toDouble() < 0))));
  }

  static List<Transaction> flatTransactions(final Iterable<Transaction> transactions) {
    List<Transaction> flatList = [];
    for (final t in transactions) {
      if (t.isSplit) {
        for (final s in t.splits) {
          final fakeTransaction = Transaction(status: t.status.value);
          fakeTransaction.dateTime.value = t.dateTime.value;
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

  DateRange dateRangeIncludingClosedAccount = DateRange();
  DateRange dateRangeActiveAccount = DateRange();

  double runningBalance = 0.00;

  @override
  void loadDemoData() {
    _loadDemoData();
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }

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

  @override
  void onAllDataLoaded() {
    // Now that everything is loaded, lets resolve the Transfers

    for (final Transaction transactionSource in iterableList()) {
      dateRangeIncludingClosedAccount.inflate(transactionSource.dateTime.value!);
      if (transactionSource.accountInstance?.isOpen == true) {
        dateRangeActiveAccount.inflate(transactionSource.dateTime.value!);
      }

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
              'Transaction.transferID of ${transactionSource.uniqueId} missing related transaction id $transferId');
          continue;
        }

        // hydrate the Transfer
        if (transactionSource.transferSplit.value == -1) {
          // Normal direct transfer
          // ignore: prefer_conditional_assignment
          if (transactionSource.transferInstance == null) {
            // cache the transfer
            transactionSource.transferInstance =
                Transfer(id: 0, source: transactionSource, related: transactionRelated, isOrphan: false);
          }
          // ignore: prefer_conditional_assignment
          if (transactionRelated.transferInstance == null) {
            // cache the transfer
            transactionRelated.transferInstance =
                Transfer(id: 0, source: transactionRelated, related: transactionSource, isOrphan: false);
          }
          continue;
        }
      }
    }

    // make sure that we have valid min max dates
    dateRangeIncludingClosedAccount.ensureNoNullDates();
    dateRangeActiveAccount.ensureNoNullDates();
  }

  int getNextTransactionId() {
    int maxIdFound = -1;
    for (final item in iterableList(includeDeleted: true)) {
      maxIdFound = max(maxIdFound, item.id.value);
    }
    return maxIdFound + 1;
  }

  Transaction? findExistingTransaction({
    required final DateTime dateTime,
    required final String payeeAsText,
    required final double amount,
  }) {
    // TODO make this more precises, at the moment we only match amount and date YYYY,MM,DD
    return iterableList(includeDeleted: true).firstWhereOrNull((transaction) {
      if (transaction.amount.value.toDouble() == amount) {
        if (transaction.dateTime.value?.year == dateTime.year &&
            transaction.dateTime.value?.month == dateTime.month &&
            transaction.dateTime.value?.day == dateTime.day) {
          return true;
        }
      }
      return false;
    });
  }

  Transaction? findExistingTransactionForAccount({
    required final int accountId,
    required final DateTime dateTime,
    required final double amount,
  }) {
    // TODO - make this more precises, at the moment we only match amount and date YYYY,MM,DD
    return iterableList(includeDeleted: true).firstWhereOrNull((transaction) {
      if (transaction.accountId.value == accountId && transaction.amount.value.toDouble() == amount) {
        if (transaction.dateTime.value?.year == dateTime.year &&
            transaction.dateTime.value?.month == dateTime.month &&
            transaction.dateTime.value?.day == dateTime.day) {
          return true;
        }
      }
      return false;
    });
  }

  List<Transaction> getAllTransactionsByDate() {
    final List<Transaction> theListOfAllTransactionIncludingHiddenOne = iterableList().toList(growable: false);
    theListOfAllTransactionIncludingHiddenOne.sort(
      (final Transaction a, final Transaction b) => sortByDate(a.dateTime.value, b.dateTime.value, true),
    );
    return theListOfAllTransactionIncludingHiddenOne;
  }
}
