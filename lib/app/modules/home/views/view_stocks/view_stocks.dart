import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/date_range.dart';
import 'package:money/app/data/models/fields/field_filter.dart';
import 'package:money/app/data/models/money_objects/investments/investments.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/views/adaptive_view/adaptive_list/adaptive_columns_or_rows_single_seletion.dart';
import 'package:money/app/modules/home/views/view_money_objects.dart';
import 'package:money/app/modules/home/views/view_stocks/stock_chart.dart';
import 'package:money/app/core/widgets/center_message.dart';
import 'package:money/app/core/widgets/columns/footer_widgets.dart';

class ViewStocks extends ViewForMoneyObjects {
  const ViewStocks({
    super.key,
  });

  @override
  State<ViewForMoneyObjects> createState() => ViewStocksState();
}

class ViewStocksState extends ViewForMoneyObjectsState {
  ViewStocksState() {
    viewId = ViewId.viewStocks;
  }

  // Footer related
  final DateRange _footerColumnDate = DateRange();
  int _footerColumnTrades = 0;
  double _footerColumnShares = 0.00;
  double _footerColumnBalance = 0.00;

  Security? lastSecuritySelected;
  final ValueNotifier<SortingInstruction> _sortingInstruction = ValueNotifier<SortingInstruction>(SortingInstruction());

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
  String getViewId() {
    return Data().securities.getTypeName();
  }

  @override
  Fields<Security> getFieldsForTable() {
    return Security.fields;
  }

  @override
  List<Security> getList({bool includeDeleted = false, bool applyFilter = true}) {
    final List<Security> list = Data().securities.iterableList(includeDeleted: includeDeleted).toList();
    _footerColumnDate.clear();

    for (final item in list) {
      _footerColumnDate.inflate(item.priceDate.value);
      _footerColumnTrades += item.numberOfTrades.value;
      _footerColumnShares += item.outstandingShares.value;
      _footerColumnBalance += item.balance.getValueForDisplay(item).toDouble();
    }

    return list;
  }

  @override
  Widget getInfoPanelViewChart({
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

  @override
  Widget getInfoPanelViewTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    lastSecuritySelected = getMoneyObjectFromFirstSelectedId<Security>(selectedIds, getList());
    if (lastSecuritySelected == null) {
      return const CenterMessage(message: 'No security selected.');
    }
    final exclude = ['Symbol', 'Load', 'Fees'];
    final List<Field> fieldsToDisplay = Investment.fields.definitions
        .where((element) => element.useAsColumn && !exclude.contains(element.name))
        .toList();

    return ValueListenableBuilder<SortingInstruction>(
      valueListenable: _sortingInstruction,
      builder: (final BuildContext context, final SortingInstruction sortInstructions, final Widget? _) {
        List<Investment> list = getListOfInvestment(lastSecuritySelected!);

        MoneyObjects.sortList(list, fieldsToDisplay, sortInstructions.column, sortInstructions.ascending);
        return AdaptiveListColumnsOrRowsSingleSelection(
          // list
          list: list,
          fieldDefinitions: fieldsToDisplay,
          filters: FieldFilters(),
          sortByFieldIndex: sortInstructions.column,
          sortAscending: sortInstructions.ascending,
          selectedId: -1,
          // Field & Columns
          displayAsColumns: true,
          backgoundColorForHeaderFooter: Colors.transparent,
          onColumnHeaderTap: (int columnHeaderIndex) {
            if (columnHeaderIndex == sortInstructions.column) {
              // toggle order
              sortInstructions.ascending = !sortInstructions.ascending;
            } else {
              sortInstructions.column = columnHeaderIndex;
            }
            _sortingInstruction.value = sortInstructions.clone();
          },
        );
      },
    );
  }

  @override
  Widget? getColumnFooterWidget(final Field field) {
    switch (field.name) {
      case 'Date':
        return getFooterForDateRange(_footerColumnDate);
      case 'Trades':
        return getFooterForInt(_footerColumnTrades);
      case 'Shares':
        return getFooterForInt(_footerColumnShares.toInt());
      case 'Balance':
        return getFooterForAmount(_footerColumnBalance);
      default:
        return null;
    }
  }

  List<Investment> getListOfInvestment(Security security) {
    final List<Investment> list = Investments.getInvestmentsFromSecurity(security.uniqueId);
    Investments.calculateRunningBalance(list);
    return list;
  }
}

class SortingInstruction {
  int column = 0;
  bool ascending = false;

  SortingInstruction clone() {
    // Create a new instance with the same properties
    return SortingInstruction()
      // ignore: unnecessary_this
      ..column = this.column
      // ignore: unnecessary_this
      ..ascending = this.ascending;
  }
}
