import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_entities/aliases/alias.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_entities/rentals/rental_unit/rental_unit.dart';
import 'package:money/models/money_entities/transactions/transaction.dart';
import 'package:money/views/view.dart';
import 'package:money/widgets/table_view/table_transactions.dart';

class ViewAliases extends ViewWidget<Alias> {
  const ViewAliases({super.key});

  @override
  State<ViewWidget<Alias>> createState() => ViewAliasesState();
}

class ViewAliasesState extends ViewWidgetState<Alias> {
  @override
  getClassNamePlural() {
    return 'Aliases';
  }

  @override
  getClassNameSingular() {
    return 'Alias';
  }

  @override
  String getDescription() {
    return 'Payee aliases.';
  }

  @override
  FieldDefinitions<Alias> getFieldDefinitionsForTable() {
    return FieldDefinitions<Alias>(definitions: <FieldDefinition<Alias>>[
      Alias.getFieldForPayee(),
      Alias.getFieldForPattern(),
      Alias.getFieldForType(),
    ]);
  }

  @override
  FieldDefinitions<Alias> getFieldDefinitionsForDetailsPanel() {
    final FieldDefinitions<Alias> fields = FieldDefinitions<Alias>(definitions: <FieldDefinition<Alias>>[
      Alias.getFieldForPattern(),
      Alias.getFieldForType(),
    ]);

    return fields;
  }

  getUnitsAsString(final List<RentUnit> listOfUnits) {
    final List<String> listAsText = <String>[];
    for (RentUnit unit in listOfUnits) {
      listAsText.add('${unit.name}:${unit.renter}');
    }

    return listAsText.join('\n');
  }

  @override
  List<Alias> getList() {
    return Data().aliases.moneyObjects.getAsList();
  }

  @override
  getDefaultSortColumn() {
    return 0; // Sort by name
  }

  @override
  Widget getPanelForChart(final List<int> indices) {
    return const Text('No chart for Aliases');
  }

  @override
  Widget getPanelForTransactions(final List<int> indices) {
    final Alias? alias = getFirstElement<Alias>(indices, list);
    if (alias != null && alias.id > -1) {
      return TableTransactions(
        key: Key(alias.id.toString()),
        columnsToInclude: const <String>[
          columnIdAccount,
          columnIdDate,
          columnIdCategory,
          columnIdMemo,
          columnIdAmount,
        ],
        getList: () => getFilteredTransactions(
          (final Transaction transaction) => transaction.payeeId == alias.payeeId,
        ),
      );
    }
    return const Text('No transactions');
  }
}
