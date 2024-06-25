import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/date_range.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/payees/payee.dart';
import 'package:money/app/data/models/money_objects/transactions/transactions.dart';
import 'package:money/app/controller/general_controller.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/app/modules/home/sub_views/view_money_objects.dart';
import 'package:money/app/modules/home/sub_views/view_payees/merge_payees.dart';
import 'package:money/app/core/widgets/center_message.dart';
import 'package:money/app/core/widgets/chart.dart';
import 'package:money/app/core/widgets/columns/footer_widgets.dart';
import 'package:money/app/core/widgets/date_range_time_line.dart';
import 'package:money/app/core/widgets/dialog/dialog_button.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/mini_timeline_daily.dart';

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

  // Footer related
  int _footerCountTransactions = 0;
  double _footerSumBalance = 0.00;

  /// add more top leve action buttons
  @override
  List<Widget> getActionsForSelectedItems(final bool forInfoPanelTransactions) {
    final list = super.getActionsForSelectedItems(forInfoPanelTransactions);
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
                ViewId.viewTransactions.getIconData(),
                'Switch to Transactions',
                () {
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
  String getViewId() {
    return Data().payees.getTypeName();
  }

  @override
  Widget? getColumnFooterWidget(final Field field) {
    switch (field.name) {
      case 'Transactions':
        return getFooterForInt(_footerCountTransactions);
      case 'Sum':
        return getFooterForAmount(_footerSumBalance);
      default:
        return null;
    }
  }

  @override
  List<Payee> getList({bool includeDeleted = false, bool applyFilter = true}) {
    var list = Data()
        .payees
        .iterableList(includeDeleted: includeDeleted)
        .where((instance) => (applyFilter == false || isMatchingFilters(instance)))
        .toList();

    _footerCountTransactions = 0;
    _footerSumBalance = 0.00;

    for (final item in list) {
      _footerCountTransactions += item.count.value.toInt();
      _footerSumBalance += item.sum.value.toDouble();
    }

    return list;
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
  Fields<Payee> getFieldsForTable() {
    return Payee.fields;
  }
}
