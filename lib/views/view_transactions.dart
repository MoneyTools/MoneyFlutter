import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/models/data.dart';
import 'package:money/models/transactions.dart';

import 'package:money/helpers.dart';
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
  ViewTransactionsState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    return Expanded(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Column(children: <Widget>[
              Header(
                  "Transactions",
                  intValueOrDefault(Transactions.list.length),
                  "Details actions of your accounts."),
              Row(children: <Widget>[
                Expanded(
                    child: Container(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Text("Account",
                            textAlign: TextAlign.left,
                            style: textTheme.titleMedium))),
                Expanded(
                    child: Container(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Text("Date",
                            textAlign: TextAlign.left,
                            style: textTheme.titleMedium))),
                Expanded(
                    child: Container(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Text("Payee",
                            textAlign: TextAlign.left,
                            style: textTheme.titleMedium))),
                Expanded(
                    child: Container(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Text("Amount",
                            textAlign: TextAlign.right,
                            style: textTheme.titleMedium))),
                Expanded(
                    child: Container(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Text("Balance",
                            textAlign: TextAlign.right,
                            style: textTheme.titleMedium))),
              ]),
              Expanded(
                  child: ListView.builder(
                      itemCount: Transactions.list.length,
                      itemExtent: 30,
                      // cacheExtent: 30*10000,
                      itemBuilder: (context, index) {
                        return Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                  widget.data.accounts.getNameFromId(
                                      Transactions.list[index].accountId),
                                  textAlign: TextAlign.left),
                            ),
                            Expanded(
                              child: Text(
                                  Transactions.list[index].dateTime
                                      .toIso8601String()
                                      .split('T')
                                      .first,
                                  textAlign: TextAlign.left),
                            ),
                            Expanded(
                              child: Text(
                                  widget.data.payees.getNameFromId(
                                      Transactions.list[index].payeeId),
                                  textAlign: TextAlign.left),
                            ),
                            Expanded(
                              child: Text(
                                  formatCurrency
                                      .format(Transactions.list[index].amount),
                                  textAlign: TextAlign.right),
                            ),
                            Expanded(
                              child: Text(
                                  formatCurrency
                                      .format(Transactions.list[index].balance),
                                  textAlign: TextAlign.right),
                            ),
                          ],
                        );
                      })),
            ])));
  }
}
