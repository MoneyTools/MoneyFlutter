import 'package:flutter/material.dart';
import 'package:money/helpers.dart';
import 'package:money/models/categories.dart';
import 'package:money/models/transactions.dart';
import 'package:money/widgets/caption_and_counter.dart';
import 'package:money/widgets/header.dart';

import '../models/accounts.dart';
import '../models/payees.dart';
import '../widgets/columns.dart';
import '../widgets/widget_view.dart';

const String columnIdAccount = "Accounts";
const String columnIdDate = "Date";
const String columnIdPayee = "Payee";
const String columnIdCategory = "Category";
const String columnIdAmount = "Amount";
const String columnIdBalance = "Balance";

const ViewWidgetToDisplay preferenceFullView = ViewWidgetToDisplay(columnsToInclude: [columnIdAccount, columnIdDate, columnIdPayee, columnIdAmount, columnIdBalance]);

const ViewWidgetToDisplay preferenceJustTableDatePayeeCategoryAmountBalance =
    ViewWidgetToDisplay(showTitle: false, showBottom: false, expandAndPadding: false, columnsToInclude: [columnIdDate, columnIdPayee, columnIdCategory, columnIdAmount, columnIdBalance]);

class ViewTransactions extends ViewWidget {
  final double startingBalance;

  const ViewTransactions({super.key, super.filter, super.preference = preferenceFullView, this.startingBalance = 0.00});

  @override
  State<ViewWidget> createState() => ViewTransactionsState();
}

class ViewTransactionsState extends ViewWidgetState {
  final styleHeader = const TextStyle(fontWeight: FontWeight.w600, fontSize: 20);
  final List<Widget> pivots = [];
  final List<bool> _selectedPivot = <bool>[false, false, true];

  bool balanceDone = false;

  @override
  void initState() {
    super.initState();

    super.sortAscending = false;

    pivots.add(CaptionAndCounter(caption: "Incomes", small: true, vertical: true, value: Transactions.list.where((element) => element.amount > 0).length));
    pivots.add(CaptionAndCounter(caption: "Expenses", small: true, vertical: true, value: Transactions.list.where((element) => element.amount < 0).length));
    pivots.add(CaptionAndCounter(caption: "All", small: true, vertical: true, value: Transactions.list.length));
  }

  @override
  getClassNamePlural() {
    return "Transactions";
  }

  @override
  getClassNameSingular() {
    return "Transaction";
  }

  @override
  getDescription() {
    return "Details actions of your accounts.";
  }

  @override
  Widget getTitle() {
    return Column(children: [
      Header(getClassNamePlural(), numValueOrDefault(list.length), getDescription()),
      renderToggles(),
    ]);
  }

  @override
  getList() {
    var list = Transactions.list.where((transaction) => isMatchingIncomeExpense(transaction) && widget.filter(transaction)).toList();

    if(!balanceDone) {
      list.sort((a, b) => sortByStringIgnoreCase(getDateAsText(a.dateTime), getDateAsText(b.dateTime)));

      var runningBalance = 0.0;
      for (var transaction in list) {
        runningBalance += transaction.amount;
        transaction.balance = runningBalance;
      }
      balanceDone = true;
    }
    return list;
  }

  isMatchingIncomeExpense(transaction) {
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
  }

  @override
  ColumnDefinitions getColumnDefinitionsForTable() {
    List<ColumnDefinition> listOfColumns = [];

    for (var columnId in widget.preference.columnsToInclude) {
      listOfColumns.add(getColumnDefinitionFromId(columnId));
    }

    return ColumnDefinitions(listOfColumns);
  }

  getColumnDefinitionFromId(id) {
    switch (id) {
      case columnIdAccount:
        return ColumnDefinition(
          columnIdAccount,
          ColumnType.text,
          TextAlign.left,
          /* cell */ (index) {
            return Accounts.getNameFromId(list[index].accountId);
          },
          /* Sort */ (a, b, ascending) {
            return sortByString(Accounts.getNameFromId(a.accountId), Accounts.getNameFromId(b.accountId), ascending);
          },
        );
      case columnIdDate:
        return ColumnDefinition(columnIdDate, ColumnType.date, TextAlign.left, /* Cell */ (index) {
          return getDateAsText(list[index].dateTime);
        }, /* Sort */ (a, b, ascending) {
          return sortByString(getDateAsText(a.dateTime), getDateAsText(b.dateTime), sortAscending);
        });

      case columnIdPayee:
        return ColumnDefinition(
          columnIdPayee,
          ColumnType.text,
          TextAlign.left,
          /* Cell */ (index) {
            return Payees.getNameFromId(list[index].payeeId);
          },
          /* Sort */ (a, b, ascending) {
            return sortByString(Payees.getNameFromId(a.payeeId), Payees.getNameFromId(b.payeeId), sortAscending);
          },
        );

      case columnIdCategory:
        return ColumnDefinition(
          columnIdCategory,
          ColumnType.text,
          TextAlign.left,
          /* Cell */ (index) {
            return Categories.getNameFromId(list[index].categoryId);
          },
          /* Sort */ (a, b, ascending) {
            return sortByString(Categories.getNameFromId(a.categoryId), Categories.getNameFromId(b.categoryId), sortAscending);
          },
        );

      case columnIdAmount:
        return ColumnDefinition(
          columnIdAmount,
          ColumnType.amount,
          TextAlign.right,
          /* Cell */ (index) {
            return list[index].amount;
          },
          /* Sort */ (a, b, ascending) {
            return sortByValue(a.amount, b.amount, sortAscending);
          },
        );

      case columnIdBalance:
        return ColumnDefinition(columnIdBalance, ColumnType.amount, TextAlign.right, /* Cell */ (index) {
          return list[index].balance;
        }, /* Sort */ (a, b, ascending) {
          return sortByValue(a.balance, b.balance, sortAscending);
        });
    }
  }

  @override
  getDefaultSortColumn() {
    // We want to default to sort by Date on startup
    // regardless of where the "Data Column" is
    var columnIndex = 0;
    for (var columnId in widget.preference.columnsToInclude) {
      if (columnId == columnIdDate) {
        return columnIndex;
      }
      columnIndex++;
    }
    return columnIndex;
  }

  renderToggles() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: ToggleButtons(
          direction: Axis.horizontal,
          onPressed: (int index) {
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
}
