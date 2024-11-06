// ignore_for_file: prefer_conditional_assignment

import 'package:money/core/helpers/accumulator.dart';
import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/data/models/money_objects/accounts/account.dart';
import 'package:money/data/models/money_objects/transactions/transaction.dart';
import 'package:money/data/models/money_objects/transfers/transfer.dart';
import 'package:money/data/storage/data/data.dart';

export 'package:money/data/models/money_objects/transactions/transaction.dart';

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
    // We use this to give a Hint to the user about the best category to pick for a transaction
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
          linkTransfer(transactionSource, transactionRelated);
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

  void checkTransfers(Set<Transaction> dangling, List<Account> deletedAccounts) {
    for (Transaction t in iterableList()) {
      t.checkTransfers(dangling, deletedAccounts);
    }
  }

  /// match amount and date YYYY,MM,DD, optionally restrict to a specific account by passing -1
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
          final Transaction fakeTransaction = Transaction(date: t.fieldDateTime.value, status: t.fieldStatus.value);
          fakeTransaction.fieldAccountId.value = t.fieldAccountId.value;
          fakeTransaction.fieldPayee.value = t.fieldPayee.value;
          fakeTransaction.fieldCategoryId.value = s.fieldCategoryId.value;
          fakeTransaction.fieldMemo.value = s.fieldMemo.value;
          fakeTransaction.fieldAmount.value = s.fieldAmount.value;
          flatList.add(fakeTransaction);
        }
      } else {
        flatList.add(t);
      }
    }
    return flatList;
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

  static List<Pair<DateTime, double>> transactionSumByYearly(List<Transaction> transactions) {
    Map<int, double> yearSums = {};
    for (final t in transactions) {
      final year = t.fieldDateTime.value!.year;
      yearSums[year] = (yearSums[year] ?? 0) + t.fieldAmount.value.toDouble();
    }

    List<Pair<DateTime, double>> summedYears = [];
    yearSums.forEach((year, sum) {
      summedYears.add(Pair(DateTime(year), sum));
    });

    // Sort by year
    summedYears.sort((a, b) => a.first.compareTo(b.first));
    return summedYears;
  }

  static List<Pair<DateTime, double>> transactionSumDaily(List<Transaction> transactions) {
    List<Pair<DateTime, double>> timeAndAmounts = [];
    for (final t in transactions) {
      DateTime date = DateTime(t.fieldDateTime.value!.year, t.fieldDateTime.value!.month, t.fieldDateTime.value!.day);
      timeAndAmounts.add(Pair<DateTime, double>(date, t.fieldAmount.value.toDouble()));
    }
    // sort by date time
    timeAndAmounts.sort((a, b) => a.first.compareTo(b.first));
    return timeAndAmounts;
  }

  static List<Pair<DateTime, double>> transactionSumMonthly(List<Transaction> transactions) {
    Map<DateTime, double> monthSums = {};

    for (final t in transactions) {
      final date = t.fieldDateTime.value!;
      // Create a DateTime object representing the first day of the month.
      final firstDayOfMonth = DateTime(date.year, date.month);
      monthSums[firstDayOfMonth] = (monthSums[firstDayOfMonth] ?? 0) + t.fieldAmount.value.toDouble();
    }

    List<Pair<DateTime, double>> summedMonths = [];
    monthSums.forEach((key, value) {
      summedMonths.add(Pair(key, value));
    });

    // Sort by date
    summedMonths.sort((a, b) => a.first.compareTo(b.first));
    return summedMonths;
  }

  static List<Pair<DateTime, double>> transactionSumWeekly(List<Transaction> transactions) {
    Map<DateTime, double> weekSums = {};

    for (final t in transactions) {
      final date = t.fieldDateTime.value!;
      // Get the first day of the week (Sunday).
      final firstDayOfWeek = date.subtract(Duration(days: date.weekday));
      weekSums[firstDayOfWeek] = (weekSums[firstDayOfWeek] ?? 0) + t.fieldAmount.value.toDouble();
    }

    List<Pair<DateTime, double>> summedWeeks = [];
    weekSums.forEach((key, value) {
      summedWeeks.add(Pair(key, value));
    });

    // Sort by date
    summedWeeks.sort((a, b) => a.first.compareTo(b.first));
    return summedWeeks;
  }
}
