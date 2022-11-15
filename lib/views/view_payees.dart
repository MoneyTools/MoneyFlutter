import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/models/data.dart';

import 'package:money/helpers.dart';
import 'package:money/widgets/header.dart';

class ViewPayees extends StatefulWidget {
  final Data data;

  const ViewPayees({super.key, required this.data});

  @override
  State<ViewPayees> createState() => ViewPayeesState();
}

class ViewPayeesState extends State<ViewPayees> {
  final formatCurrency = NumberFormat("#,##0.00", "en_US");
  ViewPayeesState();

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
              Header("Payees", numValueOrDefault(widget.data.payees.list.length),
                  "Who is getting your money."),
              Row(children: <Widget>[
                Expanded(
                    child: Container(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Text("Name",
                            textAlign: TextAlign.left,
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
                      itemCount: widget.data.payees.list.length,
                      itemExtent: 30,
                      // cacheExtent: 30*10000,
                      itemBuilder: (context, index) {
                        return Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(widget.data.payees.list[index].name,
                                  textAlign: TextAlign.left),
                            ),
                            Expanded(
                              child: Text(formatCurrency.format(0.00),
                                  textAlign: TextAlign.right),
                            ),
                          ],
                        );
                      })),
            ])));
  }
}
