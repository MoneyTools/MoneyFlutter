import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/loan_payments/loan_payments.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/widgets/center_message.dart';
import 'package:money/widgets/chart.dart';
import 'package:money/views/view.dart';
import 'package:money/widgets/list_view/transactions/list_view_transactions.dart';

part 'view_loans_details_panels.dart';

class ViewLoans extends ViewWidget<LoanPayment> {
  const ViewLoans({super.key});

  @override
  State<ViewWidget<LoanPayment>> createState() => ViewLoansState();
}

class ViewLoansState extends ViewWidgetState<LoanPayment> {
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
  List<LoanPayment> getList([bool includeDeleted = false]) {
    return Data().loanPayments.iterableList(includeDeleted).toList();
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
  void onDeleteConfirmedByUser(final MoneyObject instance) {
    setState(() {
      Data().loanPayments.deleteItem(instance);
    });
  }
}
