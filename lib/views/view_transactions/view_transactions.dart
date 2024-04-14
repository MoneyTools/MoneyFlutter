import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/widgets/list_view/transactions/list_view_transaction_splits.dart';
import 'package:money/views/view_money_objects.dart';
import 'package:money/widgets/widgets.dart';

class ViewTransactions extends ViewForMoneyObjects {
  final double startingBalance;

  const ViewTransactions({
    super.key,
    this.startingBalance = 0.00,
  });

  @override
  State<ViewForMoneyObjects> createState() => ViewTransactionsState();
}

class ViewTransactionsState extends ViewForMoneyObjectsState {
  final TextStyle styleHeader = const TextStyle(fontWeight: FontWeight.w600, fontSize: 20);
  final List<Widget> pivots = <Widget>[];
  final List<bool> _selectedPivot = <bool>[false, false, true];
  bool balanceDone = false;

  @override
  void initState() {
    super.initState();

    pivots.add(ThreePartLabel(
        text1: 'Incomes',
        small: true,
        isVertical: true,
        text2: getIntAsText(Data()
            .transactions
            .iterableList()
            .where((final Transaction element) => element.amount.value.amount > 0)
            .length)));
    pivots.add(ThreePartLabel(
        text1: 'Expenses',
        small: true,
        isVertical: true,
        text2: getIntAsText(Data()
            .transactions
            .iterableList()
            .where((final Transaction element) => element.amount.value.amount < 0)
            .length)));
    pivots.add(ThreePartLabel(
        text1: 'All', small: true, isVertical: true, text2: getIntAsText(Data().transactions.iterableList().length)));
  }

  @override
  String getClassNamePlural() {
    return 'Transactions';
  }

  @override
  String getClassNameSingular() {
    return 'Transaction';
  }

  @override
  String getDescription() {
    return 'Details actions of your accounts.';
  }

  @override
  void onDeleteConfirmedByUser(final MoneyObject instance) {
    setState(() {
      Data().transactions.deleteItem(instance);
    });
  }

  @override
  Fields<Transaction> getFieldsForTable() {
    return Transaction.fields;
  }

  @override
  List<Transaction> getList({bool includeDeleted = false, bool applyFilter = true}) {
    final List<Transaction> list = Data()
        .transactions
        .iterableList(includeDeleted)
        .where((final Transaction transaction) =>
            isMatchingIncomeExpense(transaction) && (applyFilter == false || isMatchingFilters(transaction)))
        .toList();

    if (!balanceDone) {
      list.sort((final Transaction a, final Transaction b) => sortByDate(a.dateTime.value, b.dateTime.value));

      double runningBalance = 0.0;

      for (Transaction transaction in list) {
        runningBalance += transaction.amount.value.amount;
        transaction.balance = runningBalance;
      }
      balanceDone = true;
    }
    return list;
  }

  bool isMatchingIncomeExpense(final Transaction transaction) {
    if (_selectedPivot[2]) {
      return true;
    }

    // Expenses
    if (_selectedPivot[1]) {
      return transaction.amount.value.amount < 0;
    }

    // Incomes
    if (_selectedPivot[0]) {
      return transaction.amount.value.amount > 0;
    }
    return false;
  }

  Widget renderToggles() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: ToggleButtons(
          direction: Axis.horizontal,
          onPressed: (final int index) {
            setState(() {
              for (int i = 0; i < _selectedPivot.length; i++) {
                _selectedPivot[i] = i == index;
              }
              list = getList();
            });
          },
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 100.0,
          ),
          isSelected: _selectedPivot,
          children: pivots,
        ));
  }

  @override
  Widget getPanelForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final Map<String, num> tallyPerMonths = <String, num>{};

    final DateRange timePeriod =
        DateRange(min: DateTime.now().subtract(const Duration(days: 356)).startOfDay, max: DateTime.now().endOfDay);

    getList().forEach((final Transaction transaction) {
      transaction;

      if (timePeriod.isBetweenEqual(transaction.dateTime.value)) {
        final num value = transaction.amount.value.amount;

        final DateTime date = transaction.dateTime.value!;
        // Format the date as year-month string (e.g., '2023-11')
        final String yearMonth = '${date.year}-${date.month.toString().padLeft(2, '0')}';

        // Update the map or add a new entry
        tallyPerMonths.update(yearMonth, (final num total) => total + value, ifAbsent: () => value);
      }
    });

    final List<PairXY> list = <PairXY>[];
    tallyPerMonths.forEach((final String key, final num value) {
      list.add(PairXY(key, value));
    });

    list.sort((final PairXY a, final PairXY b) => a.xText.compareTo(b.xText));

    return Chart(
      list: list,
      variableNameHorizontal: 'Month',
      variableNameVertical: 'Transactions',
    );
  }

  @override
  Widget getPanelForTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final Transaction? transaction = getMoneyObjectFromFirstSelectedId<Transaction>(selectedIds, list);
    //
    // If the category of this transaction is a Split then list the details of the Split
    //
    if (transaction != null && transaction.categoryId.value == Data().categories.splitCategoryId()) {
      // this is Split get the split transactions
      return ListViewTransactionSplits(
        key: Key('split_transactions ${transaction.uniqueId}'),
        getList: () {
          return Data()
              .splits
              .iterableList()
              .where((final Split s) => s.transactionId.value == transaction.id.value)
              .toList();
        },
      );
    }
    return const CenterMessage(message: 'No related transactions');
  }
}
