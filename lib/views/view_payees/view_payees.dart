import 'package:flutter/material.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/payees/payee.dart';

import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/widgets/center_message.dart';

import 'package:money/widgets/chart.dart';
import 'package:money/views/view.dart';
import 'package:money/widgets/confirmation_dialog.dart';
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
  Widget getPanelForTransactions(final List<int> indices) {
    return _getSubViewContentForTransactions(indices);
  }

  @override
  void onDelete(final BuildContext context, final int index) {
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return DeleteConfirmationDialog(
          icon: const Icon(Icons.delete),
          title: 'Delete Payee',
          question: 'Are you sure you want to delete this payee?',
          content: Column(
            children: getFieldsForTable().getListOfFieldNameAndValuePairAsWidget(list[index]),
          ),
          onConfirm: () {
            // Delete the item
            setState(() {
              Data().payees.deleteItem(list[index]);
            });
          },
        );
      },
    );
  }
}
