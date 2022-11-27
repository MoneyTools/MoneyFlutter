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
  final List<ColumnDefinition> columns = [
    ColumnDefinition("Name", TextAlign.left, () {}),
    ColumnDefinition("Balance", TextAlign.right, () {}),
  ];

  @override
  final list = Payees.list;

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
    return Header("Payees", numValueOrDefault(list.length), "Who is getting your money.");
  }

  @override
  Widget getRow(list, index) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(list[index].name, textAlign: TextAlign.left),
        ),
        Expanded(
          child: Text(formatCurrency.format(list[index].balance), textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
