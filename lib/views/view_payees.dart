import 'package:flutter/material.dart';
import 'package:money/helpers.dart';

import 'package:money/models/payees.dart';
import 'package:money/widgets/columns.dart';
import 'package:money/widgets/widget_bar_chart.dart';
import 'package:money/widgets/widget_view.dart';

class ViewPayees extends ViewWidget<Payee> {
  const ViewPayees({super.key});

  @override
  State<ViewWidget<Payee>> createState() => ViewPayeesState();
}

class ViewPayeesState extends ViewWidgetState<Payee> {
  @override
  getClassNamePlural() {
    return 'Payees';
  }

  @override
  getClassNameSingular() {
    return 'Payee';
  }

  @override
  String getDescription() {
    return 'Who is getting your money.';
  }

  @override
  ColumnDefinitions<Payee> getColumnDefinitionsForTable() {
    return ColumnDefinitions<Payee>(list: <ColumnDefinition<Payee>>[
      ColumnDefinition<Payee>(
        name: 'Name',
        type: ColumnType.text,
        align: TextAlign.left,
        value: (final int index) {
          return list[index].name;
        },
        sort: (final Payee a, final Payee b, final bool sortAscending) {
          return sortByString(a.name, b.name, sortAscending);
        },
      ),
      ColumnDefinition<Payee>(
        name: 'Count',
        type: ColumnType.numeric,
        align: TextAlign.right,
        value: (final int index) {
          return list[index].count;
        },
        sort: (final Payee a, final Payee b, final bool sortAscending) {
          return sortByValue(
            a.count,
            b.count,
            sortAscending,
          );
        },
      ),
      ColumnDefinition<Payee>(
        name: 'Balance',
        type: ColumnType.amount,
        align: TextAlign.right,
        value: (final int index) {
          return list[index].balance;
        },
        sort: (final Payee a, final Payee b, final bool sortAscending) {
          return sortByValue(
            a.balance,
            b.balance,
            sortAscending,
          );
        },
      ),
    ]);
  }

  @override
  List<Payee> getList() {
    return Payees.moneyObjects.getAsList();
  }

  @override
  getDefaultSortColumn() {
    return 0; // Sort by name
  }

  @override
  Widget getSubViewContentForChart(final List<num> indices) {
    final List<PairXY> list = <PairXY>[];
    for (final Payee item in getList()) {
      if (item.name != 'Transfer') {
        list.add(PairXY(item.name, item.count));
      }
    }

    list.sort((final PairXY a, final PairXY b) {
      return (b.yValue.abs() - a.yValue.abs()).toInt();
    });

    return WidgetBarChart(
      key: Key(indices.toString()),
      list: list.take(10).toList(),
      variableNameHorizontal: 'Payee',
      variableNameVertical: 'Transactions',
    );
  }
}
