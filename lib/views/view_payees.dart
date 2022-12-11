import 'package:flutter/material.dart';
import 'package:money/helpers.dart';
import 'package:money/widgets/header.dart';

import '../models/payees.dart';
import '../widgets/columns.dart';
import '../widgets/widget_view.dart';

class ViewPayees extends ViewWidget {
  const ViewPayees({super.key});

  @override
  State<ViewWidget> createState() => ViewPayeesState();
}

class ViewPayeesState extends ViewWidgetState {
  @override
  getClassNamePlural() {
    return "Payees";
  }

  @override
  getClassNameSingular() {
    return "Payee";
  }

  @override
  String getDescription() {
    return "Who is getting your money.";
  }

  @override
  ColumnDefinitions getColumnDefinitions() {
    return ColumnDefinitions([
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
    ]);
  }

  @override
  getList() {
    return Payees.moneyObjects.getAsList();
  }

  @override
  getDefaultSortColumn() {
    return 0; // Sort by name
  }
}
