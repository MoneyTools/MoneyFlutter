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
  List<ColumnDefinition> columns = [
    ColumnDefinition("Name", TextAlign.left, () {}),
    ColumnDefinition("Type", TextAlign.center, () {}),
    ColumnDefinition("Balance", TextAlign.right, () {}),
  ];
  @override
  var list = Accounts.getOpenAccounts();

  @override
  onSort() {
    switch (sortBy) {
      case 0:
        list.sort((a, b) {
          if (sortAscending) {
            return a.name.toUpperCase().compareTo(b.name.toUpperCase());
          } else {
            return b.name.toUpperCase().compareTo(a.name.toUpperCase());
          }
        });
        break;
      case 1:
        list.sort((a, b) {
          if (sortAscending) {
            return a.getTypeAsText().compareTo(b.getTypeAsText());
          } else {
            return b.getTypeAsText().compareTo(a.getTypeAsText());
          }
        });
        break;
      case 2:
        list.sort((a, b) {
          if (sortAscending) {
            return (a.balance - b.balance).toInt();
          } else {
            return (b.balance - a.balance).toInt();
          }
        });
        break;
    }
  }

  @override
  Widget getTitle() {
    return Header("Accounts", numValueOrDefault(list.length), "Your main assets.");
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
