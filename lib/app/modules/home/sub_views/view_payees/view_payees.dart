import 'dart:math';

import 'package:money/app/controller/selection_controller.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/ranges.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/date_range_time_line.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/mini_timeline_daily.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/payees/payee.dart';
import 'package:money/app/data/models/money_objects/transactions/transactions.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/view_money_objects.dart';
import 'package:money/app/modules/home/sub_views/view_payees/merge_payees.dart';

part 'view_payees_details_panels.dart';

class ViewPayees extends ViewForMoneyObjects {
  const ViewPayees({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewPayeesState();
}

class ViewPayeesState extends ViewForMoneyObjectsState {
  ViewPayeesState() {
    viewId = ViewId.viewPayees;
  }

  /// add more top leve action buttons
  @override
  List<Widget> getActionsButtons(final bool forInfoPanelTransactions) {
    final list = super.getActionsButtons(forInfoPanelTransactions);
    if (!forInfoPanelTransactions) {
      /// Merge
      final MoneyObject? moneyObject = getFirstSelectedItem();
      if (moneyObject != null) {
        list.add(
          buildMergeButton(
            () {
              // let the user pick another Payee and merge change the transaction of the current selected payee to the destination
              final payee = (moneyObject as Payee);
              showMergePayee(context, payee);
            },
          ),
        );
      }

      // this can go last
      if (getFirstSelectedItem() != null) {
        list.add(
          buildJumpToButton(
            [
              InternalViewSwitching(
                icon: ViewId.viewTransactions.getIconData(),
                title: 'Switch to Transactions',
                onPressed: () {
                  final Payee? payee = getFirstSelectedItem() as Payee?;
                  if (payee != null) {
                    // Prepare the Transaction view to show only the selected account
                    switchViewTransacionnForPayee(payee.name.value);
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
    return 'Payees';
  }

  @override
  String getClassNameSingular() {
    return 'Payee';
  }

  @override
  String getDescription() {
    return 'Who is getting your money.';
  }

  @override
  Fields<Payee> getFieldsForTable() {
    return Payee.fields;
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
  List<MoneyObject> getInfoTransactions() {
    final Payee? payee = getFirstSelectedItem() as Payee?;
    if (payee != null && payee.id.value > -1) {
      return getTransactions(
        filter: (final Transaction transaction) => transaction.payee.value == payee.id.value,
      );
    }
    return [];
  }

  @override
  List<Payee> getList({bool includeDeleted = false, bool applyFilter = true}) {
    var list = Data()
        .payees
        .iterableList(includeDeleted: includeDeleted)
        .where(
          (instance) => (applyFilter == false || isMatchingFilters(instance)),
        )
        .toList();

    return list;
  }

  @override
  String getViewId() {
    return Data().payees.getTypeName();
  }
}
