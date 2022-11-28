import 'package:flutter/material.dart';
import 'package:money/helpers.dart';
import 'package:money/widgets/header.dart';

import '../models/payees.dart';
import '../widgets/columns.dart';
import '../widgets/virtualTable.dart';

class ViewPayees extends MyView {
  const ViewPayees({super.key});

  @override
  State<MyView> createState() => ViewPayeesState();
}

class ViewPayeesState extends MyViewState {
  @override
  Widget getTitle() {
    return Header("Payees", numValueOrDefault(list.length), "Who is getting your money.");
  }

  @override
  List<ColumnDefinition> getColumnDefinitions() {
    return [
      ColumnDefinition("Name", ColumnType.text, TextAlign.left, (a, b, sortAscending) {
        return sortByString(a.name, b.name, sortAscending);
      }),
      ColumnDefinition("Balance", ColumnType.amount, TextAlign.right, (a, b, sortAscending) {
        return sortByValue(a.balance, b.balance, sortAscending);
      }),
    ];
  }

  @override
  getList() {
    return Payees.list;
  }

  @override
  getDefaultSortColumn() {
    return 0; // Sort by name
  }

  @override
  Widget getRow(list, index) {
    return Row(
      children: <Widget>[
        getCell(0, list[index].name),
        getCell(1, list[index].balance),
      ],
    );
  }
}
