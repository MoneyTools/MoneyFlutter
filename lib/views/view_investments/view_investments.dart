import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/investments/investments.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/widgets/center_message.dart';

import 'package:money/widgets/chart.dart';
import 'package:money/views/view_money_objects.dart';
import 'package:money/views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';

part 'view_investments_details_panels.dart';

class ViewInvestments extends ViewForMoneyObjects {
  const ViewInvestments({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewInvestmentsState();
}

class ViewInvestmentsState extends ViewForMoneyObjectsState {
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
  List<Investment> getList({bool includeDeleted = false, bool applyFilter = true}) {
    final list = Data()
        .investments
        .iterableList(includeDeleted: includeDeleted)
        .where((instance) => (applyFilter == false || isMatchingFilters(instance)))
        .toList();
    Investments.calculateRunningBalance(list);
    return list;
  }

  @override
  Widget getInfoPanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForChart(selectedIds: selectedIds, showAsNativeCurrency: showAsNativeCurrency);
  }

  @override
  Widget getInfoPanelViewTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForTransactions(selectedIds);
  }

  @override
  Fields<Investment> getFieldsForTable() {
    return Investment.fields;
  }

  @override
  void onDeleteConfirmedByUser(final MoneyObject instance) {
    setState(() {
      Data().investments.deleteItem(instance);
    });
  }
}
