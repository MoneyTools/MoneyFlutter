import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/box.dart';
import 'package:money/app/core/widgets/dialog/dialog_mutate_money_object.dart';
import 'package:money/app/data/models/money_objects/currencies/currency.dart';
import 'package:money/app/data/models/money_objects/investments/investments.dart';
import 'package:money/app/data/models/money_objects/investments/stock_cumulative.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';
import 'package:money/app/data/models/money_objects/stock_splits/stock_split.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/adaptive_columns_or_rows_single_seletion.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/view_money_objects.dart';
import 'package:money/app/modules/home/sub_views/money_object_card.dart';
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

  final List<Widget> _pivots = <Widget>[];
  final ValueNotifier<SortingInstruction> _sortingInstruction = ValueNotifier<SortingInstruction>(SortingInstruction());

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
      final profit = security.profit.getValueForDisplay(security).toDouble();
      sumAll += profit;

      if (isConsideredZero(security.holdingShares.value)) {
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
              InternalViewSwitching.toAccounts(accountId: selectedInvestment.transactionInstance!.accountId.value),
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
              InternalViewSwitching.toInvestments(symbol: selectedSecurity.symbol.value),
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
    return Security.fields;
  }

  @override
  Widget getInfoPanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final Security? security = getFirstSelectedItem() as Security?;
    if (security != null) {
      final String symbol = security.symbol.value;
      List<Investment> list = getListOfInvestment(security);

      final List<HoldingActivity> events = [];
      for (final Investment activity in list) {
        if (activity.effectiveUnits != 0) {
          events.add(
            HoldingActivity(
              activity.transactionInstance!.dateTime.value!,
              activity.unitPriceAdjusted.getValueForDisplay(activity),
              activity.effectiveUnitsAdjusted,
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

    return ValueListenableBuilder<SortingInstruction>(
      valueListenable: _sortingInstruction,
      builder: (
        final BuildContext context,
        final SortingInstruction sortInstructions,
        final Widget? _,
      ) {
        return AdaptiveListColumnsOrRowsSingleSelection(
          // list related
          list: getListOfInvestment(_lastSecuritySelected!),
          fieldDefinitions:
              _getFieldsToDisplayForInfoPanelTransactions(_lastSecuritySelected!.splitsHistory.isNotEmpty),
          filters: FieldFilters(),
          sortByFieldIndex: sortInstructions.column,
          sortAscending: sortInstructions.ascending,
          selectedId: getInfoPanelLastSelectedItemId(),
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
          onSelectionChanged: (int uniqueId) {
            setState(() {
              PreferenceController.to.setInt(
                getPreferenceKey('info_$settingKeySelectedListItemId'),
                uniqueId,
              );
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

  @override
  String getViewId() {
    return Data().securities.getTypeName();
  }

  List<Investment> getListOfInvestment(Security security) {
    final List<Investment> list = Investments.getInvestmentsForThisSecurity(security.uniqueId);
    Investments.applyHoldingSharesAjustedForSplits(list);
    return list;
  }

  bool isMatchingPivot(final Security instance) {
    if (_selectedPivot[0]) {
      // No holding of stock
      return isConsideredZero(instance.holdingShares.value);
    }
    if (_selectedPivot[1]) {
      // Still have holding
      return !isConsideredZero(instance.holdingShares.value);
    }
    if (_selectedPivot[2]) {
      // All, no filter needed
    }
    return true;
  }

  Widget _buildAdaptiveBox({
    required final BuildContext context,
    required final String title,
    required final int count,
    required final Widget content,
    final Widget? footer,
  }) {
    return Box(
      height: 300,
      color: getColorTheme(context).primaryContainer,
      header: buildHeaderTitleAndCounter(context, title, count == 0 ? '' : getIntAsText(count)),
      footer: footer,
      padding: SizeForPadding.huge,
      child: count == 0 ? CenterMessage(message: 'No $title found') : content,
    );
  }

  Widget _buildPanelForDividend(final BuildContext context, final Security security) {
    final double totalDividend = security.dividends.fold(0.0, (sum, dividend) => sum + dividend.amount);

    return _buildAdaptiveBox(
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

    return _buildAdaptiveBox(
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
              Text(split.date.getValueForDisplay(split).toString()),
              Text(split.numerator.value.toString()),
              const Text(' for '),
              Text(split.denominator.value.toString()),
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
          (element) => element.useAsColumn && included.contains(element.name),
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
