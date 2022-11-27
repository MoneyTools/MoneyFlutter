import 'package:flutter/material.dart';
import 'package:money/helpers.dart';
import 'package:money/models/transactions.dart';
import 'package:money/widgets/caption_and_counter.dart';
import 'package:money/widgets/header.dart';

import '../models/accounts.dart';
import '../models/payees.dart';
import '../widgets/columns.dart';
import '../widgets/virtualTable.dart';

class ViewTransactions extends MyView {
  const ViewTransactions({super.key});

  @override
  State<MyView> createState() => ViewTransactionsState();
}

class ViewTransactionsState extends MyViewState {
  final styleHeader = const TextStyle(fontWeight: FontWeight.w600, fontSize: 20);
  final List<Widget> options = [];
  final List<bool> _selectedExpenseIncome = <bool>[false, false, true];

  @override
  List<ColumnDefinition> getColumnDefinitions() {
    return [
      ColumnDefinition("Account", TextAlign.left, (a, b, ascending) {
        var textA = Accounts.getNameFromId(a.accountId);
        var textB = Accounts.getNameFromId(b.accountId);
        return sortByString(textA, textB, ascending);
      }),
      ColumnDefinition("Date", TextAlign.left, (a, b, ascending) {
        var textA = a.dateTime.toIso8601String().split('T').first;
        var textB = b.dateTime.toIso8601String().split('T').first;
        return sortByString(textA, textB, sortAscending);
      }),
      ColumnDefinition("Payee", TextAlign.left, (a, b, ascending) {
        var textA = Payees.getNameFromId(a.payeeId);
        var textB = Payees.getNameFromId(b.payeeId);
        return sortByString(textA, textB, sortAscending);
      }),
      ColumnDefinition("Amount", TextAlign.right, (a, b, ascending) {
        return sortByValue(a.amount, b.amount, sortAscending);
      }),
      ColumnDefinition("Balance", TextAlign.right, (a, b, ascending) {
        return sortByValue(a.balance, b.balance, sortAscending);
      }),
    ];
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

  @override
  Widget getRow(list, index) {
    return Row(
      children: <Widget>[
        renderColumValueEntryText(Accounts.getNameFromId(list[index].accountId)),
        renderColumValueEntryText(list[index].dateTime.toIso8601String().split('T').first),
        renderColumValueEntryText(Payees.getNameFromId(list[index].payeeId)),
        renderColumValueEntryCurrency(list[index].amount),
        renderColumValueEntryCurrency(list[index].balance),
      ],
    );
  }

  Widget renderColumValueEntryText(text) {
    return Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.fromLTRB(0, 0, 8, 0), child: Text(text, textAlign: TextAlign.left))));
  }

  Widget renderColumValueEntryCurrency(value) {
    return Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.fromLTRB(1, 0, 1, 0), child: Text(formatCurrency.format(value), textAlign: TextAlign.right))));
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
