import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/widgets/box.dart';
import 'package:money/core/widgets/dialog/dialog_mutate_money_object.dart';
import 'package:money/data/models/money_objects/currencies/currency.dart';
import 'package:money/data/models/money_objects/investments/investments.dart';
import 'package:money/data/models/money_objects/investments/stock_cumulative.dart';
import 'package:money/data/models/money_objects/securities/security.dart';
import 'package:money/data/models/money_objects/stock_splits/stock_split.dart';
import 'package:money/data/storage/data/data.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/adaptive_columns_or_rows_single_selection.dart';
import 'package:money/views/home/sub_views/adaptive_view/view_money_objects.dart';
import 'package:money/views/home/sub_views/money_object_card.dart';
import 'package:money/views/home/sub_views/view_stocks/stock_chart.dart';

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

  final List<Widget> _pivots = <Widget>[];

  // Filter related
  final List<bool> _selectedPivot = <bool>[false, false, true];

  Security? _lastSecuritySelected;

  @override
  Widget buildHeader([final Widget? child]) {
    List<Security> list = getList(
      includeDeleted: false,
      applyFilter: false,
    );

    double sumActive = 0.00;
    double sumClosed = 0.00;
    double sumAll = 0.00;

    for (final Security security in list) {
      final profit = security.fieldProfit.getValueForDisplay(security).toDouble();
      sumAll += profit;

      if (isConsideredZero(security.fieldHoldingShares.value)) {
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

  /// add more top menu or info panel action buttons
  @override
  List<Widget> getActionsButtons(final bool forInfoPanelTransactions) {
    final List<Widget> list = super.getActionsButtons(forInfoPanelTransactions);
    if (forInfoPanelTransactions) {
      final Investment? selectedInvestment = getInfoPanelLastSelectedItem<Investment>(Data().investments);
      if (selectedInvestment != null) {
        list.add(
          buildJumpToButton(
            [
              InternalViewSwitching.toAccounts(accountId: selectedInvestment.transactionInstance!.fieldAccountId.value),
              InternalViewSwitching.toTransactions(transactionId: selectedInvestment.uniqueId),
            ],
          ),
        );
      }
    } else {
      final Security? selectedSecurity = getFirstSelectedItem() as Security?;
      // this can go last
      if (selectedSecurity != null) {
        list.add(
          buildJumpToButton(
            [
              // Jump to Investment view
              InternalViewSwitching.toInvestments(symbol: selectedSecurity.fieldSymbol.value),
            ],
          ),
        );
      }
    }
    return list;
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
    return Security.fieldsForColumnView;
  }

  @override
  Widget getInfoPanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final Security? security = getFirstSelectedItem() as Security?;
    if (security != null) {
      final String symbol = security.fieldSymbol.value;
      List<Investment> list = getListOfInvestment(security);

      final List<ChartEvent> events = [];
      for (final Investment activity in list) {
        if (activity.effectiveUnits != 0) {
          events.add(
            ChartEvent(
              date: activity.transactionInstance!.fieldDateTime.value!,
              amount: activity.fieldUnitPriceAdjusted.getValueForDisplay(activity),
              quantity: activity.effectiveUnitsAdjusted,
              colorBasedOnQuantity: true,
              description: activity.fieldInvestmentType.getValueForDisplay(activity),
            ),
          );
        }
      }

      if (symbol.isNotEmpty) {
        return StockChartWidget(
          key: Key('stock_symbol_$symbol'),
          symbol: symbol,
          splits: Data().stockSplits.getStockSplitsForSecurity(security),
          dividends: security.dividends,
          holdingsActivities: events,
        );
      }
    }
    return const Center(child: Text('No stock selected'));
  }

  @override
  Widget getInfoPanelViewDetails({
    required final List<int> selectedIds,
    required final bool isReadOnly,
  }) {
    final selectedSecurity = getFirstSelectedItem() as Security?;
    if (selectedSecurity == null) {
      return const CenterMessage(message: 'No item selected.');
    }

    return SingleChildScrollView(
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 30,
          spacing: 30,
          children: [
            MoneyObjectCard(
              title: getClassNameSingular(),
              moneyObject: selectedSecurity,
            ),
            _buildPanelForSplits(context, selectedSecurity),
            _buildPanelForDividend(context, selectedSecurity),
          ],
        ),
      ),
    );
  }

  @override
  Widget getInfoPanelViewTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    _lastSecuritySelected = getFirstSelectedItem() as Security?;

    if (_lastSecuritySelected == null) {
      return const CenterMessage(message: 'No security selected.');
    }

    final listOfInvestmentsForThisStock = getListOfInvestment(_lastSecuritySelected!);

    int sortByFieldIndex = PreferenceController.to.getInt(getPreferenceKey('info_$settingKeySortBy'), 0);
    bool sortAscending = PreferenceController.to.getBool(getPreferenceKey('info_$settingKeySortAscending'), false);

    final fields = _getFieldsToDisplayForInfoPanelTransactions(_lastSecuritySelected!.splitsHistory.isNotEmpty);

    MoneyObjects.sortList(
      listOfInvestmentsForThisStock,
      fields,
      sortByFieldIndex,
      sortAscending,
    );

    return AdaptiveListColumnsOrRowsSingleSelection(
      // list related
      list: listOfInvestmentsForThisStock,
      fieldDefinitions: _getFieldsToDisplayForInfoPanelTransactions(_lastSecuritySelected!.splitsHistory.isNotEmpty),
      filters: FieldFilters(),
      sortByFieldIndex: sortByFieldIndex,
      sortAscending: sortAscending,
      selectedId: getInfoPanelLastSelectedItemId(),
      // Field & Columns related
      displayAsColumns: true,
      backgroundColorForHeaderFooter: Colors.transparent,
      onColumnHeaderTap: (int columnHeaderIndex) {
        setState(() {
          if (columnHeaderIndex == sortByFieldIndex) {
            // toggle order
            sortAscending = !sortAscending;
            PreferenceController.to.setBool(getPreferenceKey('info_$settingKeySortAscending'), sortAscending);
          } else {
            sortByFieldIndex = columnHeaderIndex;
            PreferenceController.to.setInt(getPreferenceKey('info_$settingKeySortBy'), sortByFieldIndex);
          }
        });
      },
      onSelectionChanged: (int uniqueId) {
        setState(() {
          PreferenceController.to.setInt(getPreferenceKey('info_$settingKeySelectedListItemId'), uniqueId);
        });
      },
      onItemLongPress: (BuildContext context2, int itemId) {
        final instance = Data().investments.get(itemId);
        if (instance != null) {
          myShowDialogAndActionsForMoneyObject(
            title: 'Investment',
            context: context2,
            moneyObject: instance,
          );
        }
      },
    );
  }

  @override
  List<MoneyObject> getInfoTransactions() {
    return getListOfInvestment(_lastSecuritySelected!);
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

  List<Investment> getListOfInvestment(Security security) {
    final List<Investment> list = Investments.getInvestmentsForThisSecurity(security.uniqueId);
    Investments.applyHoldingSharesAdjustedForSplits(list);
    return list;
  }

  bool isMatchingPivot(final Security instance) {
    if (_selectedPivot[0]) {
      // No holding of stock
      return isConsideredZero(instance.fieldHoldingShares.value);
    }
    if (_selectedPivot[1]) {
      // Still have holding
      return !isConsideredZero(instance.fieldHoldingShares.value);
    }
    if (_selectedPivot[2]) {
      // All, no filter needed
    }
    return true;
  }

  Widget _buildPanelForDividend(final BuildContext context, final Security security) {
    final double totalDividend = security.dividends.fold(0.0, (sum, dividend) => sum + dividend.amount);

    return buildAdaptiveBox(
      context: context,
      title: 'Dividend',
      count: security.dividends.length,
      content: ListView.separated(
        itemCount: security.dividends.length,
        itemBuilder: (context, index) {
          final Dividend dividend = security.dividends[index];
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dividend.date.toString()),
              Text(Currency.getAmountAsStringUsingCurrency(dividend.amount)),
            ],
          );
        },
        separatorBuilder: (context, index) => Divider(
          color: getColorTheme(context).onPrimaryContainer.withAlpha(100),
        ),
      ),
      footer: Box.buildFooter(Currency.getAmountAsStringUsingCurrency(totalDividend)),
    );
  }

  Widget _buildPanelForSplits(final BuildContext context, final Security security) {
    final List<StockSplit> splits = security.splitsHistory;

    return buildAdaptiveBox(
      context: context,
      title: 'Splits',
      count: splits.length,
      content: ListView.separated(
        itemCount: splits.length,
        itemBuilder: (context, index) {
          final StockSplit split = splits[index];
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(split.fieldDate.getValueForDisplay(split).toString()),
              Text(split.fieldNumerator.value.toString()),
              const Text(' for '),
              Text(split.fieldDenominator.value.toString()),
            ],
          );
        },
        separatorBuilder: (context, index) => Divider(
          color: getColorTheme(context).onPrimaryContainer.withAlpha(100),
        ),
      ),
    );
  }

  List<Field<dynamic>> _getFieldsToDisplayForInfoPanelTransactions(bool includeSplitColumns) {
    final included = [
      'Date',
      'Account',
      'Activity',
      'Units',
      if (includeSplitColumns) 'Split',
      if (includeSplitColumns) 'Units A.S.',
      'Holding',
      'Price',
      if (includeSplitColumns) 'Price A.S.',
      'HoldingValue',
      'Commission',
      'ActivityAmount',
    ];
    final List<Field> fieldsToDisplay = Investment.fields.definitions
        .where(
          (element) => included.contains(element.name),
        )
        .toList();
    return fieldsToDisplay;
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
