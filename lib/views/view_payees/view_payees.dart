import 'package:flutter/material.dart';
import 'package:money/helpers.dart';

import 'package:money/models/payees.dart';
import 'package:money/models/transactions.dart';
import 'package:money/views/view_transactions.dart';
import 'package:money/widgets/columns.dart';
import 'package:money/widgets/widget_bar_chart.dart';
import 'package:money/widgets/widget_view.dart';

part 'view_payees_columns.dart';

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
    return _getColumnDefinitionsForTable();
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
  Widget getSubViewContentForChart(final List<int> indices) {
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

  @override
  getSubViewContentForTransactions(final List<int> indices) {
    final Payee? payee = getFirstElement<Payee>(indices, list);
    if (payee != null && payee.id > -1) {
      return ViewTransactions(
        key: Key(payee.id.toString()),
        filter: (final Transaction transaction) => transaction.payeeId == payee.id,
        preference: preferenceJustTableDatePayeeCategoryAmountBalance,
        startingBalance: 0,
      );
    }
    return const Text('No transactions');
  }
}
