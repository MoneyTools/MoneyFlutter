import 'package:flutter/material.dart';
import 'package:money/helpers.dart';
import 'package:money/models/transactions.dart';
import 'package:money/widgets/caption_and_counter.dart';
import 'package:money/widgets/header.dart';

import '../models/accounts.dart';
import '../models/payees.dart';
import '../widgets/columns.dart';
import '../widgets/widget_view.dart';

class ViewTransactions extends ViewWidget {
  const ViewTransactions({super.key, super.setDetailsPanelContent});

  @override
  State<ViewWidget> createState() => ViewTransactionsState();
}

class ViewTransactionsState extends ViewWidgetState {
  final styleHeader = const TextStyle(fontWeight: FontWeight.w600, fontSize: 20);
  final List<Widget> options = [];
  final List<bool> _selectedExpenseIncome = <bool>[false, false, true];

  @override
  ColumnDefinitions getColumnDefinitions() {
    return ColumnDefinitions([
      ColumnDefinition(
        "Account",
        ColumnType.text,
        TextAlign.left,
        /* cell */ (index) {
          return Accounts.getNameFromId(list[index].accountId);
        },
        /* Sort */ (a, b, ascending) {
          return sortByString(Accounts.getNameFromId(a.accountId), Accounts.getNameFromId(b.accountId), ascending);
        },
      ),
      ColumnDefinition(
        "Date",
        ColumnType.date,
        TextAlign.left,
        /* Cell */ (index) {
          return getDateAsText(list[index].dateTime);
        },
        /* Sort */ (a, b, ascending) {
          return sortByString(getDateAsText(a.dateTime), getDateAsText(b.dateTime), sortAscending);
        },
      ),
      ColumnDefinition(
        "Payee",
        ColumnType.text,
        TextAlign.left,
        /* Cell */ (index) {
          return Payees.getNameFromId(list[index].payeeId);
        },
        /* Sort */ (a, b, ascending) {
          return sortByString(Payees.getNameFromId(a.payeeId), Payees.getNameFromId(b.payeeId), sortAscending);
        },
      ),
      ColumnDefinition(
        "Amount",
        ColumnType.amount,
        TextAlign.right,
        /* Cell */ (index) {
          return list[index].amount;
        },
        /* Sort */ (a, b, ascending) {
          return sortByValue(a.amount, b.amount, sortAscending);
        },
      ),
      ColumnDefinition(
        "Balance",
        ColumnType.amount,
        TextAlign.right,
        /* Cell */ (index) {
          return list[index].balance;
        },
        /* Sort */ (a, b, ascending) {
          return sortByValue(a.balance, b.balance, sortAscending);
        },
      ),
    ]);
  }

  @override
  getDefaultSortColumn() {
    return 1; // Sort By Date
  }

  ViewTransactionsState();

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
    // All
    if (_selectedExpenseIncome[2]) {
      return Transactions.list;
    }
    // Expanses
    if (_selectedExpenseIncome[1]) {
      return Transactions.list.where((element) => element.amount < 0).toList();
    }

    // Incomes
    if (_selectedExpenseIncome[0]) {
      return Transactions.list.where((element) => element.amount > 0).toList();
    }
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
