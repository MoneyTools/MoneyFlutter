import 'package:flutter/material.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/loans/loan.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/widgets/chart.dart';
import 'package:money/views/view.dart';
import 'package:money/widgets/table_view/table_transactions.dart';

part 'view_loans_details_panels.dart';

class ViewLoans extends ViewWidget<Loan> {
  const ViewLoans({super.key});

  @override
  State<ViewWidget<Loan>> createState() => ViewLoansState();
}

class ViewLoansState extends ViewWidgetState<Loan> {
  @override
  getClassNameSingular() {
    return 'Loan';
  }

  @override
  getClassNamePlural() {
    return 'Loans';
  }

  @override
  String getDescription() {
    return 'Properties to rent.';
  }

  @override
  FieldDefinitions<Loan> getFieldDefinitionsForTable() {
    return FieldDefinitions<Loan>(definitions: <FieldDefinition<Loan>>[
      Loan.getFieldForAccountName(),
      Loan.getFieldForMemo(),
    ]);
  }

  @override
  FieldDefinitions<Loan> getFieldDefinitionsForDetailsPanel() {
    final FieldDefinitions<Loan> fields =
        FieldDefinitions<Loan>(definitions: <FieldDefinition<Loan>>[Loan.getFieldForMemo()]);

    return fields;
  }

  @override
  List<Loan> getList() {
    return Data().loans.moneyObjects.getAsList();
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
