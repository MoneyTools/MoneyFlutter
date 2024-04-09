import 'package:flutter/material.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/securities/security.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view.dart';
import 'package:money/views/view_stocks/stock_chart.dart';

class ViewStocks extends ViewWidget {
  const ViewStocks({
    super.key,
  });

  @override
  State<ViewWidget> createState() => ViewStocksState();
}

class ViewStocksState extends ViewWidgetState {
  @override
  String getClassNamePlural() {
    return 'Stocks';
  }

  @override
  String getClassNameSingular() {
    return 'Stock';
  }

  @override
  String getDescription() {
    return 'Stocks tracking.';
  }

  @override
  Fields<Security> getFieldsForTable() {
    return Security.getFields();
  }

  @override
  List<Security> getList({bool includeDeleted = false, bool applyFilter = true}) {
    final List<Security> list = Data().securities.iterableList(includeDeleted).toList();
    return list;
  }

  @override
  Widget getPanelForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final Security? selected = getFirstSelectedItem() as Security?;
    if (selected != null) {
      final String symbol = selected.symbol.value;
      if (symbol.isNotEmpty) {
        return StockChartWidget(
          key: Key('stock_symbol_$symbol'),
          symbol: symbol,
        );
      }
    }
    return const Center(child: Text('No stock selected'));
  }
}
