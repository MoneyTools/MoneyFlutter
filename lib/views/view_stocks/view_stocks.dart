import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/money_objects/investments/investments.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/securities/security.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/adaptive_view/adaptive_list/adaptive_columns_or_rows_list.dart';
import 'package:money/views/view_money_objects.dart';
import 'package:money/views/view_stocks/stock_chart.dart';
import 'package:money/widgets/center_message.dart';

class ViewStocks extends ViewForMoneyObjects {
  const ViewStocks({
    super.key,
  });

  @override
  State<ViewForMoneyObjects> createState() => ViewStocksState();
}

class ViewStocksState extends ViewForMoneyObjectsState {
  Security? lastSecuritySelected;
  final ValueNotifier<SortingInstruction> _sortingInstruction = ValueNotifier<SortingInstruction>(SortingInstruction());

  ViewStocksState() {
    onCopyInfoPanelTransactions = _onCopyInfoPanelTransactions;
  }

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
  MyJson getViewChoices() {
    return Data().securities.getLastViewChoices();
  }

  @override
  Fields<Security> getFieldsForTable() {
    return Security.fields;
  }

  @override
  List<Security> getList({bool includeDeleted = false, bool applyFilter = true}) {
    final List<Security> list = Data().securities.iterableList(includeDeleted: includeDeleted).toList();
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

        sortList(list, fieldsToDisplay, sortInstructions.column, sortInstructions.ascending);

        return AdaptiveListColumnsOrRows(
          // list
          list: list,
          fieldDefinitions: fieldsToDisplay,
          sortByFieldIndex: sortInstructions.column,
          sortAscending: sortInstructions.ascending,

          // Field & Columns
          useColumns: true,
          onColumnHeaderTap: (int columnHeaderIndex) {
            if (columnHeaderIndex == sortInstructions.column) {
              // toggle order
              sortInstructions.ascending = !sortInstructions.ascending;
            } else {
              sortInstructions.column = columnHeaderIndex;
            }
            _sortingInstruction.value = sortInstructions.clone();
          },
          selectedItemsByUniqueId: ValueNotifier<List<int>>([]),
          isMultiSelectionOn: false,
        );
      },
    );
  }

  List<Investment> getListOfInvestment(Security security) {
    final List<Investment> list = Investments.getInvestmentsFromSecurity(security.uniqueId);
    Investments.calculateRunningBalance(list);
    return list;
  }

  void _onCopyInfoPanelTransactions() {
    if (lastSecuritySelected != null) {
      final list = getListOfInvestment(lastSecuritySelected!);
      copyToClipboardAndInformUser(context, MoneyObjects.getCsvFromList(list));
    }
  }

  void sortList(
    final List<Investment> list,
    final List<Field> fieldsToDisplay,
    final int columnIndex,
    final bool sortAscending,
  ) {
    final Field<dynamic> fieldDefinition = fieldsToDisplay[columnIndex];
    if (fieldDefinition.sort == null) {
      // No sorting function found, fallback to String sorting
      list.sort((final MoneyObject a, final MoneyObject b) {
        return sortByString(
          fieldDefinition.valueFromInstance(a).toString(),
          fieldDefinition.valueFromInstance(b).toString(),
          sortAscending,
        );
      });
    } else {
      list.sort(
        (final Investment a, final Investment b) {
          return fieldDefinition.sort!(a, b, sortAscending);
        },
      );
    }
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
