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
      ColumnDefinition("Name", ColumnType.text, TextAlign.left, (a, b, sortAscending) {
        return sortByString(a.name, b.name, sortAscending);
      }),
      ColumnDefinition("Type", ColumnType.text, TextAlign.center, (a, b, sortAscending) {
        return sortByString(a.getTypeAsText(), b.getTypeAsText(), sortAscending);
      }),
      ColumnDefinition("Balance", ColumnType.amount, TextAlign.right, (a, b, sortAscending) {
        return sortByValue(a.balance, b.balance, sortAscending);
      }),
    ];
  }

  @override
  getDefaultSortColumn() {
    return 0; // Sort by name
  }

  @override
  getList() {
    return Accounts.getOpenAccounts();
  }

  @override
  Widget getRow(list, index) {
    return Row(
      children: <Widget>[
        getCell(0, list[index].name),
        getCell(1, list[index].getTypeAsText()),
        getCell(2, list[index].balance),
      ],
    );
  }
}
