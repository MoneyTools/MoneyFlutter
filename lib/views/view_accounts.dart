import 'package:flutter/material.dart';

import '../helpers.dart';
import '../models/accounts.dart';
import '../widgets/columns.dart';
import '../widgets/header.dart';
import '../widgets/virtualTable.dart';

class ViewAccounts extends MyView {
  const ViewAccounts({super.key});

  @override
  State<MyView> createState() => ViewAccountsState();
}

class ViewAccountsState extends MyViewState {

  @override
  Widget getTitle() {
    return Header("Accounts", numValueOrDefault(list.length), "Your main assets.");
  }

  @override
  List<ColumnDefinition> getColumnDefinitions() {
    return [
      ColumnDefinition("Name", TextAlign.left, (a, b, sortAscending) {
        return sortByString(a.name, b.name, sortAscending);
      }),
      ColumnDefinition("Type", TextAlign.left, (a, b, sortAscending) {
        return sortByString(a.getTypeAsText(), b.getTypeAsText(), sortAscending);
      }),
      ColumnDefinition("Balance", TextAlign.right, (a, b, sortAscending) {
        return sortByValue(a.balance, b.balance, sortAscending);
      }),
    ];
  }

  @override
  getList() {
    return Accounts.getOpenAccounts();
  }

  @override
  Widget getRow(list, index) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(list[index].name, textAlign: TextAlign.left),
        ),
        Expanded(
          child: Text(list[index].getTypeAsText(), textAlign: TextAlign.left),
        ),
        Expanded(
          child: Text(formatCurrency.format(list[index].balance), textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
