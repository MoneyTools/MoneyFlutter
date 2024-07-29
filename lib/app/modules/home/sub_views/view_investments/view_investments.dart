import 'package:fl_chart/fl_chart.dart';
import 'package:money/app/controller/selection_controller.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/widgets/charts/my_line_chart.dart';
import 'package:money/app/data/models/money_objects/investments/investments.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/view_money_objects.dart';

part 'view_investments_details_panels.dart';

class ViewInvestments extends ViewForMoneyObjects {
  const ViewInvestments({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewInvestmentsState();
}

class ViewInvestmentsState extends ViewForMoneyObjectsState {
  ViewInvestmentsState() {
    viewId = ViewId.viewInvestments;
  }

  /// add more top leve action buttons
  @override
  List<Widget> getActionsButtons(final bool forInfoPanelTransactions) {
    final list = super.getActionsButtons(forInfoPanelTransactions);
    if (!forInfoPanelTransactions) {
      final Investment? selectedInvestment = getFirstSelectedItem() as Investment?;

      // this can go last
      if (selectedInvestment != null) {
        final Transaction? relatedTransaction = Data().transactions.get(selectedInvestment.uniqueId);
        list.add(
          buildJumpToButton(
            [
              // Jump to Account view
              InternalViewSwitching.toAccounts(accountId: relatedTransaction!.accountId.value),

              // Jump to Transaction view
              InternalViewSwitching.toTransactions(
                transactionId: relatedTransaction.uniqueId,
                filters: null,
              ),

              // Jump to Stock view
              InternalViewSwitching(
                icon: ViewId.viewStocks.getIconData(),
                title: 'Switch to Stocks',
                onPressed: () {
                  // Prepare the Stocks view
                  // Filter by Stock Symbol
                  String symbol =
                      selectedInvestment.securitySymbol.getValueForDisplay(selectedInvestment).toLowerCase();
                  final Security? securityFound = Data().securities.getBySymbol(symbol);
                  if (securityFound != null) {
                    PreferenceController.to.jumpToView(
                      viewId: ViewId.viewStocks,
                      selectedId: securityFound.uniqueId,
                      columnFilter: [],
                      textFilter: '',
                    );
                  }
                },
              ),
            ],
          ),
        );
      }
    }
    return list;
  }

  @override
  String getClassNamePlural() {
    return 'Investments';
  }

  @override
  String getClassNameSingular() {
    return 'Investment';
  }

  @override
  String getDescription() {
    return 'Track your stock portfolio.';
  }

  @override
  Fields<Investment> getFieldsForTable() {
    return Investment.fieldsForColumnView;
  }

  @override
  Widget getInfoPanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForChart(
      selectedIds: selectedIds,
      showAsNativeCurrency: showAsNativeCurrency,
    );
  }

  @override
  Widget getInfoPanelViewTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForTransactions(selectedIds);
  }

  @override
  List<Investment> getList({
    bool includeDeleted = false,
    bool applyFilter = true,
  }) {
    final list = Data()
        .investments
        .iterableList(includeDeleted: includeDeleted)
        .where(
          (instance) => (applyFilter == false || isMatchingFilters(instance)),
        )
        .toList();
    Investments.applyHoldingSharesAjustedForSplits(list);

    return list;
  }

  @override
  String getViewId() {
    return Data().investments.getTypeName();
  }
}
