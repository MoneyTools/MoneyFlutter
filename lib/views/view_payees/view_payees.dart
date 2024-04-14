import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/payees/payee.dart';

import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/widgets/center_message.dart';

import 'package:money/widgets/chart.dart';
import 'package:money/views/view_money_objects.dart';
import 'package:money/widgets/list_view/transactions/list_view_transactions.dart';

part 'view_payees_details_panels.dart';

class ViewPayees extends ViewForMoneyObjects {
  const ViewPayees({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewPayeesState();
}

class ViewPayeesState extends ViewForMoneyObjectsState {
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
  List<Payee> getList({bool includeDeleted = false, bool applyFilter = true}) {
    return Data()
        .payees
        .iterableList(includeDeleted)
        .where((instance) => (applyFilter == false || isMatchingFilters(instance)))
        .toList();
  }

  @override
  Widget getPanelForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForChart(
      selectedIds: selectedIds,
      showAsNativeCurrency: showAsNativeCurrency,
    );
  }

  @override
  Widget getPanelForTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForTransactions(selectedIds);
  }

  @override
  void onDeleteConfirmedByUser(final MoneyObject instance) {
    setState(() {
      Data().payees.deleteItem(instance);
    });
  }

  @override
  Fields<Payee> getFieldsForTable() {
    return Payee.fields;
  }
}
