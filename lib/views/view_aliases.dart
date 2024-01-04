import 'package:flutter/material.dart';
import 'package:money/helpers.dart';
import 'package:money/models/aliases.dart';
import 'package:money/models/payees.dart';
import 'package:money/models/rentals.dart';
import 'package:money/widgets/columns.dart';
import 'package:money/widgets/widget_view.dart';

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

  ColumnDefinition<Alias> getColumnForPayee() {
    return ColumnDefinition<Alias>(
      name: 'Payee',
      type: ColumnType.text,
      align: TextAlign.left,
      value: (final int index) {
        return Payees.getNameFromId(list[index].payeeId);
      },
      sort: (final Alias a, final Alias b, final bool sortAscending) {
        return sortByString(Payees.getNameFromId(a.payeeId), Payees.getNameFromId(b.payeeId), sortAscending);
      },
    );
  }

  ColumnDefinition<Alias> getColumnForPattern() {
    return ColumnDefinition<Alias>(
      name: 'Pattern',
      type: ColumnType.text,
      align: TextAlign.left,
      value: (final int index) {
        return list[index].name;
      },
      sort: (final Alias a, final Alias b, final bool sortAscending) {
        return sortByString(a.name, b.name, sortAscending);
      },
    );
  }

  ColumnDefinition<Alias> getColumnForType() {
    return ColumnDefinition<Alias>(
      name: 'Type',
      type: ColumnType.text,
      align: TextAlign.left,
      value: (final int index) {
        return list[index].type.toString();
      },
      sort: (final Alias a, final Alias b, final bool sortAscending) {
        return sortByString(a.type.toString(), b.type.toString(), sortAscending);
      },
    );
  }

  @override
  ColumnDefinitions<Alias> getColumnDefinitionsForTable() {
    return ColumnDefinitions<Alias>(list: <ColumnDefinition<Alias>>[
      getColumnForPayee(),
      getColumnForPattern(),
      getColumnForType(),
    ]);
  }

  @override
  ColumnDefinitions<Alias> getColumnDefinitionsForDetailsPanel() {
    final ColumnDefinitions<Alias> fields = ColumnDefinitions<Alias>(list: <ColumnDefinition<Alias>>[
      getColumnForPattern(),
      getColumnForType(),
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
    return Aliases.moneyObjects.getAsList();
  }

  @override
  getDefaultSortColumn() {
    return 0; // Sort by name
  }

  @override
  Widget getSubViewContentForChart(final List<int> indices) {
    return const Text('No chart for Aliases');
  }

  @override
  getSubViewContentForTransactions(final List<int> indices) {
    return const Text('No transactions');
  }
}
