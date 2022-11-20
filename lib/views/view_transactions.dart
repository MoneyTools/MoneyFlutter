import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/helpers.dart';
import 'package:money/models/data.dart';
import 'package:money/models/transactions.dart';
import 'package:money/widgets/caption_and_counter.dart';
import 'package:money/widgets/header.dart';

class ViewTransactions extends StatefulWidget {
  final Data data;

  const ViewTransactions({super.key, required this.data});

  @override
  State<ViewTransactions> createState() => ViewTransactionsState();
}

class ViewTransactionsState extends State<ViewTransactions> {
  final styleHeader =
      const TextStyle(fontWeight: FontWeight.w600, fontSize: 20);
  final formatCurrency = NumberFormat("#,##0.00", "en_US");
  final List<Widget> options = [];
  final List<bool> _selectedExpenseIncome = <bool>[false, false, true];

  ViewTransactionsState();

  @override
  void initState() {
    super.initState();

    options.add(CaptionAndCounter(
        caption: "Incomes",
        small: true,
        vertical: true,
        count:
            Transactions.list.where((element) => element.amount > 0).length));
    options.add(CaptionAndCounter(
        caption: "Expenses",
        small: true,
        vertical: true,
        count:
            Transactions.list.where((element) => element.amount < 0).length));
    options.add(CaptionAndCounter(
        caption: "All",
        small: true,
        vertical: true,
        count: Transactions.list.length));
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
  Widget build(BuildContext context) {
    final textTheme = getTextTheme(context)
        .apply(displayColor: getColorTheme(context).onSurface);

    var list = getFilteredList();

    return Expanded(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Column(children: <Widget>[
              Header("Transactions", intValueOrDefault(list.length),
                  "Details actions of your accounts."),
              renderToggles(),
              Row(children: <Widget>[
                Expanded(
                    child: Container(
                        color: getColorTheme(context).secondaryContainer,
                        child: Text("Account",
                            textAlign: TextAlign.left,
                            style: textTheme.titleMedium))),
                Expanded(
                    child: Container(
                        color: getColorTheme(context).secondaryContainer,
                        child: Text("Date",
                            textAlign: TextAlign.left,
                            style: textTheme.titleMedium))),
                Expanded(
                    child: Container(
                        color: getColorTheme(context).secondaryContainer,
                        child: Text("Payee",
                            textAlign: TextAlign.left,
                            style: textTheme.titleMedium))),
                Expanded(
                    child: Container(
                        color: getColorTheme(context).secondaryContainer,
                        child: Text("Amount",
                            textAlign: TextAlign.right,
                            style: textTheme.titleMedium))),
                Expanded(
                    child: Container(
                        color: getColorTheme(context).secondaryContainer,
                        child: Text("Balance",
                            textAlign: TextAlign.right,
                            style: textTheme.titleMedium))),
              ]),
              Expanded(
                  child: ListView.builder(
                      itemCount: list.length,
                      itemExtent: 30,
                      // cacheExtent: 30*10000,
                      itemBuilder: (context, index) {
                        return Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                  widget.data.accounts
                                      .getNameFromId(list[index].accountId),
                                  textAlign: TextAlign.left),
                            ),
                            Expanded(
                              child: Text(
                                  list[index]
                                      .dateTime
                                      .toIso8601String()
                                      .split('T')
                                      .first,
                                  textAlign: TextAlign.left),
                            ),
                            Expanded(
                              child: Text(
                                  widget.data.payees
                                      .getNameFromId(list[index].payeeId),
                                  textAlign: TextAlign.left),
                            ),
                            Expanded(
                              child: Text(
                                  formatCurrency.format(list[index].amount),
                                  textAlign: TextAlign.right),
                            ),
                            Expanded(
                              child: Text(
                                  formatCurrency.format(list[index].balance),
                                  textAlign: TextAlign.right),
                            ),
                          ],
                        );
                      })),
            ])));
  }

  renderToggles() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: ToggleButtons(
          direction: Axis.horizontal,
          onPressed: (int index) {
            setState(() {
              for (int i = 0; i < _selectedExpenseIncome.length; i++) {
                _selectedExpenseIncome[i] = i == index;
              }
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
