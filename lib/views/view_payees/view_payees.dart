import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';

import 'package:money/models/payees.dart';
import 'package:money/models/transactions.dart';
import 'package:money/widgets/fields/field.dart';
import 'package:money/widgets/fields/fields.dart';
import 'package:money/widgets/chart.dart';
import 'package:money/views/view.dart';
import 'package:money/widgets/table_view/table_transactions.dart';

part 'view_payees_fields.dart';

part 'view_payees_details_panels.dart';

class ViewPayees extends ViewWidget<Payee> {
  const ViewPayees({super.key});

  @override
  State<ViewWidget<Payee>> createState() => ViewPayeesState();
}

class ViewPayeesState extends ViewWidgetState<Payee> {
  @override
  getClassNamePlural() {
    return 'Payees';
  }

  @override
  getClassNameSingular() {
    return 'Payee';
  }

  @override
  String getDescription() {
    return 'Who is getting your money.';
  }

  @override
  FieldDefinitions<Payee> getFieldDefinitionsForTable() {
    return _getFieldDefinitionsForTable();
  }

  @override
  List<Payee> getList() {
    return Payees.moneyObjects.getAsList();
  }

  @override
  getDefaultSortColumn() {
    return 0; // Sort by name
  }

  @override
  Widget getPanelForChart(final List<int> indices) {
    return _getSubViewContentForChart(indices);
  }

  @override
  Widget getPanelForTransactions(final List<int> indices) {
    return _getSubViewContentForTransactions(indices);
  }
}
