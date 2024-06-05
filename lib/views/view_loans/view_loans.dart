import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/loan_payments/loan_payments.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/views/view_money_objects.dart';
import 'package:money/widgets/center_message.dart';
import 'package:money/widgets/chart.dart';

part 'view_loans_details_panels.dart';

class ViewLoans extends ViewForMoneyObjects {
  const ViewLoans({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewLoansState();
}

class ViewLoansState extends ViewForMoneyObjectsState {
  @override
  String getClassNameSingular() {
    return 'Loan';
  }

  @override
  String getClassNamePlural() {
    return 'Loans';
  }

  @override
  String getDescription() {
    return 'Properties to rent.';
  }

  @override
  String getViewId() {
    return Data().loanPayments.getTypeName();
  }

  @override
  List<LoanPayment> getList({bool includeDeleted = false, bool applyFilter = true}) {
    return Data().loanPayments.iterableList(includeDeleted: includeDeleted).toList();
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
  Fields<LoanPayment> getFieldsForTable() {
    return LoanPayment.fields;
  }
}
