import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/widgets/confirmation_dialog.dart';
import 'package:money/widgets/table_view/table_splits.dart';
import 'package:money/widgets/three_part_label.dart';

import 'package:money/views/view_header.dart';
import 'package:money/widgets/chart.dart';

import 'package:money/views/view.dart';

class ViewTransactions extends ViewWidget<Transaction> {
  final double startingBalance;

  const ViewTransactions({super.key, super.filter, super.preference = preferenceFullView, this.startingBalance = 0.00});

  @override
  State<ViewWidget<Transaction>> createState() => ViewTransactionsState();
}

class ViewTransactionsState extends ViewWidgetState<Transaction> {
  final TextStyle styleHeader = const TextStyle(fontWeight: FontWeight.w600, fontSize: 20);
  final List<Widget> pivots = <Widget>[];
  final List<bool> _selectedPivot = <bool>[false, false, true];
  bool balanceDone = false;

  @override
  void initState() {
    super.initState();

    super.sortAscending = false;

    pivots.add(ThreePartLabel(
        text1: 'Incomes',
        small: true,
        isVertical: true,
        text2: getIntAsText(
            Data().transactions.getList().where((final Transaction element) => element.amount.value > 0).length)));
    pivots.add(ThreePartLabel(
        text1: 'Expenses',
        small: true,
        isVertical: true,
        text2: getIntAsText(
            Data().transactions.getList().where((final Transaction element) => element.amount.value < 0).length)));
    pivots.add(ThreePartLabel(
        text1: 'All', small: true, isVertical: true, text2: getIntAsText(Data().transactions.getList().length)));
  }

  @override
  getClassNamePlural() {
    return 'Transactions';
  }

  @override
  getClassNameSingular() {
    return 'Transaction';
  }

  @override
  getDescription() {
    return 'Details actions of your accounts.';
  }

  @override
  Widget getTitle() {
    return ViewHeader(
      title: getClassNamePlural(),
      count: numValueOrDefault(list.length),
      description: getDescription(),
      onFilterChanged: (final String text) {
        onFilterTextChanged(text);
      },
      child: renderToggles(),
    );
  }

  @override
  void onDelete(final BuildContext context, final int index) {
    final List<String> itemToDelete = getFieldDefinitionsForTable().getListOfFieldValueAsString(list[index]);

    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return DeleteConfirmationDialog(
          title: 'Delete Item',
          message: 'Are you sure you want to delete this item?\n\n${itemToDelete.join('\n')}',
          onConfirm: () {
            // Delete the item
            // ...
          },
        );
      },
    );
  }

  @override
  List<Transaction> getList() {
    final List<Transaction> list = Data()
        .transactions
        .getList()
        .where((final Transaction transaction) =>
            isMatchingIncomeExpense(transaction) && widget.filter(transaction) && isMatchingFilterText(transaction))
        .toList();

    if (!balanceDone) {
      list.sort((final Transaction a, final Transaction b) => a.dateTime.value.compareTo(b.dateTime.value));

      double runningBalance = 0.0;

      for (Transaction transaction in list) {
        runningBalance += transaction.amount.value;
        transaction.balance.value = runningBalance;
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
      return transaction.amount.value < 0;
    }

    // Incomes
    if (_selectedPivot[0]) {
      return transaction.amount.value > 0;
    }
    return false;
  }

  bool isMatchingFilterText(final Transaction transaction) {
    if (filterText.isEmpty) {
      return true;
    }

    final List<String> fieldInstances = getFieldDefinitionsForTable().getListOfFieldValueAsString(transaction);
    // debugLog(fieldInstances.join('|'));

    for (final String fieldInstance in fieldInstances) {
      if (fieldInstance.toString().toLowerCase().contains(filterText.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  @override
  getDefaultSortColumn() {
    // We want to default to sort by Date on startup
    // regardless of where the "Data Column" is
    int columnIndex = 0;
    for (String columnId in widget.preference.columnsToInclude) {
      if (columnId == columnIdDate) {
        return columnIndex;
      }
      columnIndex++;
    }
    return columnIndex;
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
  Widget getPanelForChart(final List<int> indices) {
    final Map<String, num> tallyPerMonths = <String, num>{};

    final DateRange timePeriod =
        DateRange(min: DateTime.now().subtract(const Duration(days: 356)).startOfDay, max: DateTime.now().endOfDay);

    getList().forEach((final Transaction transaction) {
      transaction;

      if (timePeriod.isBetweenEqual(transaction.dateTime.value)) {
        final DateTime date = transaction.dateTime.value;
        final num value = transaction.amount.value;

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
  getPanelForTransactions(final List<int> indices) {
    final Transaction? transaction = getFirstElement<Transaction>(indices, list);
    if (transaction != null &&
        transaction.id.value > -1 &&
        transaction.categoryId.value == Data().categories.splitCategoryId()) {
      final List<Split> l =
          Data().splits.getList().where((final Split s) => s.transactionId == transaction.id.value).toList();
      return TableSplits(
        key: Key('split_transactions ${transaction.id}'),
        getList: () => l,
      );
    }
    return const Text('No related transactions');
  }
}

const ViewWidgetToDisplay preferenceFullView = ViewWidgetToDisplay(columnsToInclude: <String>[
  columnIdAccount,
  columnIdDate,
  columnIdPayee,
  columnIdCategory,
  columnIdStatus,
  columnIdMemo,
  columnIdAmount,
  columnIdBalance
]);

const ViewWidgetToDisplay preferenceJustTableDatePayeeCategoryAmountBalance = ViewWidgetToDisplay(
    displayHeader: false,
    showBottom: false,
    columnsToInclude: <String>[
      columnIdDate,
      columnIdPayee,
      columnIdCategory,
      columnIdMemo,
      columnIdAmount,
      columnIdBalance
    ]);
