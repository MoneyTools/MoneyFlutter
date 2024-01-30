import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/aliases/alias.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/views/view.dart';
import 'package:money/widgets/center_message.dart';
import 'package:money/widgets/list_view/transactions/list_view_transactions.dart';

class ViewAliases extends ViewWidget<Alias> {
  const ViewAliases({super.key});

  @override
  State<ViewWidget<Alias>> createState() => ViewAliasesState();
}

class ViewAliasesState extends ViewWidgetState<Alias> {
  @override
  String getClassNamePlural() {
    return 'Aliases';
  }

  @override
  String getClassNameSingular() {
    return 'Alias';
  }

  @override
  String getDescription() {
    return 'Payee aliases.';
  }

  @override
  List<Alias> getList() {
    return Data().aliases.getList();
  }

  @override
  Widget getPanelForChart(final List<int> indices) {
    return const Text('No chart for Aliases');
  }

  @override
  Widget getPanelForTransactions(final List<int> indices) {
    final Alias? alias = getFirstElement<Alias>(indices, list);
    if (alias != null && alias.id.value > -1) {
      return ListViewTransactions(
        key: Key(alias.id.toString()),
        columnsToInclude: const <String>[
          columnIdAccount,
          columnIdDate,
          columnIdCategory,
          columnIdMemo,
          columnIdAmount,
        ],
        getList: () => getFilteredTransactions(
          (final Transaction transaction) => transaction.payeeId.value == alias.payeeId.value,
        ),
      );
    }
    return CenterMessage.noTransaction();
  }
}
