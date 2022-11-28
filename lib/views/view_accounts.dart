import 'package:flutter/material.dart';

import '../helpers.dart';
import '../models/accounts.dart';
import '../widgets/columns.dart';
import '../widgets/header.dart';
import '../widgets/widget_view.dart';

class ViewAccounts extends ViewWidget {
  const ViewAccounts({super.key});

  @override
  State<ViewWidget> createState() => ViewAccountsState();
}

class ViewAccountsState extends ViewWidgetState {
  @override
  Widget getTitle() {
    return Header("Accounts", numValueOrDefault(list.length), "Your main assets.");
  }

  @override
  List<ColumnDefinition> getColumnDefinitions() {
    return [
      ColumnDefinition(
        "Name",
        ColumnType.text,
        TextAlign.left,
        (index) {
          return list[index].name;
        },
        (a, b, sortAscending) {
          return sortByString(a.name, b.name, sortAscending);
        },
      ),
      ColumnDefinition(
        "Type",
        ColumnType.text,
        TextAlign.center,
        (index) {
          return list[index].getTypeAsText();
        },
        (a, b, sortAscending) {
          return sortByString(a.getTypeAsText(), b.getTypeAsText(), sortAscending);
        },
      ),
      ColumnDefinition(
        "Balance",
        ColumnType.amount,
        TextAlign.right,
        (index) {
          return list[index].balance;
        },
        (a, b, sortAscending) {
          return sortByValue(a.balance, b.balance, sortAscending);
        },
      ),
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
}
