import 'package:flutter/material.dart';
import 'package:money/helpers.dart';
import 'package:money/models/categories.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/transactions.dart';
import 'package:money/widgets/caption_and_counter.dart';
import 'package:money/widgets/header.dart';
import 'package:money/widgets/widget_bar_chart.dart';

import 'package:money/models/accounts.dart';
import 'package:money/models/payees.dart';
import 'package:money/widgets/columns.dart';
import 'package:money/widgets/widget_view.dart';

const String columnIdAccount = 'Accounts';
const String columnIdDate = 'Date';
const String columnIdPayee = 'Payee';
const String columnIdCategory = 'Category';
const String columnIdAmount = 'Amount';
const String columnIdBalance = 'Balance';

const ViewWidgetToDisplay preferenceFullView = ViewWidgetToDisplay(columnsToInclude: <String>[columnIdAccount, columnIdDate, columnIdPayee, columnIdAmount, columnIdBalance]);

const ViewWidgetToDisplay preferenceJustTableDatePayeeCategoryAmountBalance =
    ViewWidgetToDisplay(showTitle: false, showBottom: false, expandAndPadding: false, columnsToInclude: <String>[columnIdDate, columnIdPayee, columnIdCategory, columnIdAmount, columnIdBalance]);

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

    pivots.add(CaptionAndCounter(caption: 'Incomes', small: true, vertical: true, value: Transactions.list.where((final Transaction element) => element.amount > 0).length));
    pivots.add(CaptionAndCounter(caption: 'Expenses', small: true, vertical: true, value: Transactions.list.where((final Transaction element) => element.amount < 0).length));
    pivots.add(CaptionAndCounter(caption: 'All', small: true, vertical: true, value: Transactions.list.length));
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
    return Column(children: <Widget>[
      Header(getClassNamePlural(), numValueOrDefault(list.length), getDescription()),
      renderToggles(),
    ]);
  }

  @override
  List<Transaction> getList() {
    final List<Transaction> list = Transactions.list.where((final Transaction transaction) => isMatchingIncomeExpense(transaction) && widget.filter(transaction)).toList();

    if (!balanceDone) {
      list.sort((final Transaction a, final Transaction b) => sortByStringIgnoreCase(getDateAsText(a.dateTime), getDateAsText(b.dateTime)));

      double runningBalance = 0.0;
      for (Transaction transaction in list) {
        runningBalance += transaction.amount;
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
      return transaction.amount < 0;
    }

    // Incomes
    if (_selectedPivot[0]) {
      return transaction.amount > 0;
    }
    return false;
  }

  @override
  ColumnDefinitions<Transaction> getColumnDefinitionsForTable() {
    final List<ColumnDefinition<Transaction>> listOfColumns = <ColumnDefinition<Transaction>>[];

    for (String columnId in widget.preference.columnsToInclude) {
      listOfColumns.add(getColumnDefinitionFromId(columnId)!);
    }

    return ColumnDefinitions<Transaction>(list: listOfColumns);
  }

  ColumnDefinition<Transaction>? getColumnDefinitionFromId(final String id) {
    switch (id) {
      case columnIdAccount:
        return ColumnDefinition<Transaction>(
          name: columnIdAccount,
          type: ColumnType.text,
          align: TextAlign.left,
          value: (final int index) {
            return Accounts.getNameFromId((list[index]).accountId);
          },
          sort: (final Transaction a, final Transaction b, final bool ascending) {
            return sortByString(Accounts.getNameFromId(a.accountId), Accounts.getNameFromId(b.accountId), ascending);
          },
        );
      case columnIdDate:
        return ColumnDefinition<Transaction>(
            name: columnIdDate,
            type: ColumnType.date,
            align: TextAlign.left,
            value: (final int index) {
              return getDateAsText((list[index]).dateTime);
            },
            sort: (final Transaction a, final Transaction b, final bool ascending) {
              return sortByString(getDateAsText(a.dateTime), getDateAsText(b.dateTime), sortAscending);
            });

      case columnIdPayee:
        return ColumnDefinition<Transaction>(
          name: columnIdPayee,
          type: ColumnType.text,
          align: TextAlign.left,
          value: (final int index) {
            return Payees.getNameFromId((list[index]).payeeId);
          },
          sort: (final Transaction a, final Transaction b, final bool ascending) {
            return sortByString(Payees.getNameFromId(a.payeeId), Payees.getNameFromId(b.payeeId), sortAscending);
          },
        );

      case columnIdCategory:
        return ColumnDefinition<Transaction>(
          name: columnIdCategory,
          type: ColumnType.text,
          align: TextAlign.left,
          value: (final int index) {
            return Categories.getNameFromId((list[index]).categoryId);
          },
          sort: (final Transaction a, final Transaction b, final bool ascending) {
            return sortByString(Categories.getNameFromId(a.categoryId), Categories.getNameFromId(b.categoryId), sortAscending);
          },
        );

      case columnIdAmount:
        return ColumnDefinition<Transaction>(
          name: columnIdAmount,
          type: ColumnType.amount,
          align: TextAlign.right,
          value: (final int index) {
            return (list[index]).amount;
          },
          sort: (final Transaction a, final Transaction b, final bool ascending) {
            return sortByValue(a.amount, b.amount, sortAscending);
          },
        );

      case columnIdBalance:
        return ColumnDefinition<Transaction>(
          name: columnIdBalance,
          type: ColumnType.amount,
          align: TextAlign.right,
          value: (final int index) {
            return (list[index]).balance;
          },
          sort: (final Transaction a, final Transaction b, final bool ascending) {
            return sortByValue(a.balance, b.balance, sortAscending);
          },
        );
    }
    return null;
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
  Widget getSubViewContentForChart(final List<num> indices) {
    final Map<String, num> tallyPerMonths = <String, num>{};

    final DateRange timePeriod = DateRange(min: DateTime.now().subtract(const Duration(days: 356)).startOfDay, max: DateTime.now().endOfDay);

    getList().forEach((final Transaction transaction) {
      transaction;

      if (timePeriod.isBetweenEqual(transaction.dateTime)) {
        final DateTime date = transaction.dateTime;
        final num value = transaction.amount;

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

    return WidgetBarChart(
      list: list,
      variableNameHorizontal: 'Month',
      variableNameVertical: 'Transactions',
    );
  }
}
