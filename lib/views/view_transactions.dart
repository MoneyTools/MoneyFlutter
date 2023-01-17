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
  const ViewTransactions({super.key, super.filter, super.preference = preferenceFullView});

  @override
  State<ViewWidget> createState() => ViewTransactionsState();
}

class ViewTransactionsState extends ViewWidgetState {
  final styleHeader = const TextStyle(fontWeight: FontWeight.w600, fontSize: 20);
  final List<Widget> options = [];
  final List<bool> _selectedExpenseIncome = <bool>[false, false, true];

  @override
  void initState() {
    super.initState();

    options.add(CaptionAndCounter(caption: "Incomes", small: true, vertical: true, value: Transactions.list.where((element) => element.amount > 0).length));
    options.add(CaptionAndCounter(caption: "Expenses", small: true, vertical: true, value: Transactions.list.where((element) => element.amount < 0).length));
    options.add(CaptionAndCounter(caption: "All", small: true, vertical: true, value: Transactions.list.length));
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
    return getFilteredList();
  }

  getFilteredList() {
    return Transactions.list.where((transaction) => isMatchingIncomeExpense(transaction) && widget.filter(transaction)).toList();
  }

  isMatchingIncomeExpense(transaction) {
    if (_selectedExpenseIncome[2]) {
      return true;
    }

    // Expanses
    if (_selectedExpenseIncome[1]) {
      return transaction.amount < 0;
    }

    // Incomes
    if (_selectedExpenseIncome[0]) {
      transaction.amount > 0;
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
    return 1; // Sort By Date
  }

  renderToggles() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: ToggleButtons(
          direction: Axis.horizontal,
          onPressed: (int index) {
            setState(() {
              for (int i = 0; i < _selectedExpenseIncome.length; i++) {
                _selectedExpenseIncome[i] = i == index;
              }
              list = getList();
            });
          },
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 100.0,
          ),
          isSelected: _selectedExpenseIncome,
          children: options,
        ));
  }
}
