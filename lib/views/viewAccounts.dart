import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/accounts.dart';
import '../models/data.dart';

class ViewAccounts extends StatefulWidget {

  final Data data;

  const ViewAccounts({super.key, required this.data});

  @override
  State<ViewAccounts> createState() => _ViewAccountsState(data);
}

class _ViewAccountsState extends State<ViewAccounts> {
  final Data data;
  final formatCurrency = NumberFormat("#,##0.00", "en_US");
  var accountsOpened = Accounts.getOpenAccounts();

  _ViewAccountsState(this.data);

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
              Row(children: <Widget>[
                Expanded(child: Container(color: Theme
                    .of(context)
                    .colorScheme
                    .secondaryContainer, child: Text("Name", textAlign: TextAlign.left, style: textTheme.titleMedium))),
                Expanded(child: Container(color: Theme
                    .of(context)
                    .colorScheme
                    .secondaryContainer, child: Text("Balance", textAlign: TextAlign.right, style: textTheme.titleMedium))),
              ]),
              Expanded(
                  child: ListView.builder(
                      itemCount: accountsOpened.length,
                      itemExtent: 30,
                      // cacheExtent: 30*10000,
                      itemBuilder: (context, index) {
                        return Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(accountsOpened[index].name, textAlign: TextAlign.left),
                            ),
                            Expanded(
                              child: Text(formatCurrency.format(accountsOpened[index].balance), textAlign: TextAlign.right),
                            ),
                          ],
                        );
                      })),
            ])));
  }
}
