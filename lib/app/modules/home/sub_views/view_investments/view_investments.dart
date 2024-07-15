import 'package:flutter/material.dart';
import 'package:money/app/controller/selection_controller.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/widgets/center_message.dart';
import 'package:money/app/core/widgets/chart.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/fields/fields.dart';
import 'package:money/app/data/models/money_objects/investments/investments.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/app/modules/home/sub_views/view_money_objects.dart';

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

  @override
  String getClassNamePlural() {
    return 'Investment';
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
    return Investment.fields;
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
    Investments.calculateRunningSharesAndBalance(list);

    return list;
  }

  @override
  String getViewId() {
    return Data().investments.getTypeName();
  }
}
