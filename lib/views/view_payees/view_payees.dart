import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/models/money_objects/transactions/transactions.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_money_objects.dart';
import 'package:money/views/view_payees/merge_payees.dart';
import 'package:money/widgets/center_message.dart';
import 'package:money/widgets/chart.dart';
import 'package:money/views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/widgets/mini_timeline_daily.dart';

part 'view_payees_details_panels.dart';

class ViewPayees extends ViewForMoneyObjects {
  const ViewPayees({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewPayeesState();
}

class ViewPayeesState extends ViewForMoneyObjectsState {
  ViewPayeesState() {
    onMergeToItem = (final BuildContext context, final MoneyObject selectedPayee) {
      // let the user pick another Payee and merge change the transaction of the current selected payee to the destination
      showDialog(
        context: context,
        builder: (context) {
          return MergeTransactionsDialog(currentPayee: selectedPayee as Payee);
        },
      );
    };
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
  List<Payee> getList({bool includeDeleted = false, bool applyFilter = true}) {
    return Data()
        .payees
        .iterableList(includeDeleted: includeDeleted)
        .where((instance) => (applyFilter == false || isMatchingFilters(instance)))
        .toList();
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
