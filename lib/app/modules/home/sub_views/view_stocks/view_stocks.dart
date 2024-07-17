import 'package:money/app/data/models/money_objects/currencies/currency.dart';
import 'package:money/app/data/models/money_objects/investments/investments.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/adaptive_columns_or_rows_single_seletion.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/view_money_objects.dart';
import 'package:money/app/modules/home/sub_views/view_stocks/stock_chart.dart';

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

  Security? lastSecuritySelected;

  final List<Widget> _pivots = <Widget>[];
  final ValueNotifier<SortingInstruction> _sortingInstruction = ValueNotifier<SortingInstruction>(SortingInstruction());

  // Filter related
  final List<bool> _selectedPivot = <bool>[false, false, true];

  @override
  Widget buildHeader([final Widget? child]) {
    List<Security> list = getList(
      includeDeleted: false,
      applyFilter: false,
    );

    double sumActive = 0.00;
    double sumClosed = 0.00;
    double sumAll = 0.00;

    for (final security in list) {
      final profit = security.profit.getValueForDisplay(security).toDouble();
      sumAll += profit;

      if (isAlmostZero(security.holdingShares.value)) {
        sumClosed += profit;
      } else {
        sumActive += profit;
      }
    }

    _pivots.clear();
    _pivots.add(
      ThreePartLabel(
        text1: 'Closed',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(sumClosed),
      ),
    );

    _pivots.add(
      ThreePartLabel(
        text1: 'Active',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(sumActive),
      ),
    );

    _pivots.add(
      ThreePartLabel(
        text1: 'All',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(sumAll),
      ),
    );
    return super.buildHeader(_renderToggles());
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
  Fields<Security> getFieldsForTable() {
    return Security.fields;
  }

  @override
  Widget getInfoPanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final Security? selected = getFirstSelectedItem() as Security?;
    if (selected != null) {
      final String symbol = selected.symbol.value;
      List<Investment> list = getListOfInvestment(selected);

      final List<HoldingActivity> events = [];
      for (final Investment activity in list) {
        if (activity.effectiveUnits != 0) {
          events.add(
            HoldingActivity(
              activity.transactionInstance!.dateTime.value!,
              activity.unitPrice.value.toDouble(),
              activity.effectiveUnits,
            ),
          );
        }
      }

      if (symbol.isNotEmpty) {
        return StockChartWidget(
          key: Key('stock_symbol_$symbol'),
          symbol: symbol,
          holdingsActivities: events,
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
    lastSecuritySelected = getFirstSelectedItem() as Security?;

    if (lastSecuritySelected == null) {
      return const CenterMessage(message: 'No security selected.');
    }
    final included = [
      'Date',
      'Account',
      'Activity',
      'Units',
      'Price',
      'Commission',
      'ActivityAmount',
      'Holding',
      'HoldingValue',
    ];
    final List<Field> fieldsToDisplay = Investment.fields.definitions
        .where(
          (element) => element.useAsColumn && included.contains(element.name),
        )
        .toList();

    return ValueListenableBuilder<SortingInstruction>(
      valueListenable: _sortingInstruction,
      builder: (
        final BuildContext context,
        final SortingInstruction sortInstructions,
        final Widget? _,
      ) {
        List<Investment> list = getListOfInvestment(lastSecuritySelected!);

        MoneyObjects.sortList(
          list,
          fieldsToDisplay,
          sortInstructions.column,
          sortInstructions.ascending,
        );

        return AdaptiveListColumnsOrRowsSingleSelection(
          // list related
          list: list,
          fieldDefinitions: fieldsToDisplay,
          filters: FieldFilters(),
          sortByFieldIndex: sortInstructions.column,
          sortAscending: sortInstructions.ascending,
          selectedId: -1,
          // Field & Columns related
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
  List<Security> getList({
    bool includeDeleted = false,
    bool applyFilter = true,
  }) {
    List<Security> list = Data().securities.iterableList(includeDeleted: includeDeleted).toList();

    if (applyFilter) {
      list = list.where((final instance) => isMatchingFilters(instance) && isMatchingPivot(instance)).toList();
    }

    return list;
  }

  @override
  String getViewId() {
    return Data().securities.getTypeName();
  }

  List<Investment> getListOfInvestment(Security security) {
    final List<Investment> list = Investments.getInvestmentsForThisSecurity(security.uniqueId);
    Investments.calculateRunningSharesAndBalance(list);
    return list;
  }

  bool isMatchingPivot(final Security instance) {
    if (_selectedPivot[0]) {
      // No holding of stock
      return isAlmostZero(instance.holdingShares.value);
    }
    if (_selectedPivot[1]) {
      // Still have holding
      return !isAlmostZero(instance.holdingShares.value);
    }
    if (_selectedPivot[2]) {
      // All, no filter needed
    }
    return true;
  }

  Widget _renderToggles() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: ToggleButtons(
        direction: Axis.horizontal,
        onPressed: (final int index) {
          // ignore: invalid_use_of_protected_member
          setState(() {
            for (int i = 0; i < _selectedPivot.length; i++) {
              _selectedPivot[i] = i == index;
            }
            list = getList();
            clearSelection();
          });
        },
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        constraints: const BoxConstraints(
          minHeight: 40.0,
          minWidth: 100.0,
        ),
        isSelected: _selectedPivot,
        children: _pivots,
      ),
    );
  }
}

class SortingInstruction {
  bool ascending = false;
  int column = 0;

  SortingInstruction clone() {
    // Create a new instance with the same properties
    return SortingInstruction()
      // ignore: unnecessary_this
      ..column = this.column
      // ignore: unnecessary_this
      ..ascending = this.ascending;
  }
}
