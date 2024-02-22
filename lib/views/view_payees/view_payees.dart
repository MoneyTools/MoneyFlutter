import 'package:flutter/material.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/payees/payee.dart';

import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/widgets/center_message.dart';

import 'package:money/widgets/chart.dart';
import 'package:money/views/view.dart';
import 'package:money/widgets/list_view/transactions/list_view_transactions.dart';

part 'view_payees_details_panels.dart';

class ViewPayees extends ViewWidget<Payee> {
  const ViewPayees({super.key});

  @override
  State<ViewWidget<Payee>> createState() => ViewPayeesState();
}

class ViewPayeesState extends ViewWidgetState<Payee> {
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
  List<Payee> getList([bool includeDeleted = false]) {
    return Data().payees.iterableList(includeDeleted).toList();
  }

  @override
  Widget getPanelForChart(final List<int> indices) {
    return _getSubViewContentForChart(indices);
  }

  @override
  Widget getPanelForTransactions({
    required final List<int> selectedItems,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForTransactions(selectedItems);
  }

  @override
  void onDeleteConfirmedByUser(final Payee instance) {
    setState(() {
      Data().payees.deleteItem(instance);
    });
  }
}
