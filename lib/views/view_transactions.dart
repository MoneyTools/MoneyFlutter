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
  const ViewTransactions({super.key});

  @override
  State<ViewWidget> createState() => ViewTransactionsState();
}

class ViewTransactionsState extends ViewWidgetState {
  final styleHeader = const TextStyle(fontWeight: FontWeight.w600, fontSize: 20);
  final List<Widget> options = [];
  final List<bool> _selectedExpenseIncome = <bool>[false, false, true];

  @override
  List<ColumnDefinition> getColumnDefinitions() {
    return [
      ColumnDefinition(
        "Account",
        ColumnType.text,
        TextAlign.left,
        (index) {
          return Accounts.getNameFromId(list[index].accountId);
        },
        (a, b, ascending) {
          var textA = Accounts.getNameFromId(a.accountId);
          var textB = Accounts.getNameFromId(b.accountId);
          return sortByString(textA, textB, ascending);
        },
      ),
      ColumnDefinition(
        "Date",
        ColumnType.date,
        TextAlign.left,
        (index) {
          return list[index].dateTime.toIso8601String().split('T').first;
        },
        (a, b, ascending) {
          var textA = a.dateTime.toIso8601String().split('T').first;
          var textB = b.dateTime.toIso8601String().split('T').first;
          return sortByString(textA, textB, sortAscending);
        },
      ),
      ColumnDefinition(
        "Payee",
        ColumnType.text,
        TextAlign.left,
        (index) {
          return Payees.getNameFromId(list[index].payeeId);
        },
        (a, b, ascending) {
          var textA = Payees.getNameFromId(a.payeeId);
          var textB = Payees.getNameFromId(b.payeeId);
          return sortByString(textA, textB, sortAscending);
        },
      ),
      ColumnDefinition(
        "Amount",
        ColumnType.amount,
        TextAlign.right,
        (index) {
          return list[index].amount;
        },
        (a, b, ascending) {
          return sortByValue(a.amount, b.amount, sortAscending);
        },
      ),
      ColumnDefinition(
        "Balance",
        ColumnType.amount,
        TextAlign.right,
        (index) {
          return list[index].balance;
        },
        (a, b, ascending) {
          return sortByValue(a.balance, b.balance, sortAscending);
        },
      ),
    ];
  }

  @override
  getDefaultSortColumn() {
    return 1; // Sort By Date
  }

  ViewTransactionsState();

  @override
  void initState() {
    super.initState();

    options.add(CaptionAndCounter(caption: "Incomes", small: true, vertical: true, count: Transactions.list.where((element) => element.amount > 0).length));
    options.add(CaptionAndCounter(caption: "Expenses", small: true, vertical: true, count: Transactions.list.where((element) => element.amount < 0).length));
    options.add(CaptionAndCounter(caption: "All", small: true, vertical: true, count: Transactions.list.length));
  }

  @override
  Widget getTitle() {
    return Column(children: [
      Header("Transactions", numValueOrDefault(list.length), "Details actions of your accounts."),
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
