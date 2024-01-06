import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/aliases.dart';
import 'package:money/models/payees.dart';
import 'package:money/models/rentals.dart';
import 'package:money/models/transactions.dart';
import 'package:money/views/view_transactions.dart';
import 'package:money/widgets/fields/field.dart';
import 'package:money/widgets/fields/fields.dart';
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

  FieldDefinition<Alias> getFieldForPayee() {
    return FieldDefinition<Alias>(
      name: 'Payee',
      type: FieldType.text,
      align: TextAlign.left,
      value: (final int index) {
        return Payees.getNameFromId(list[index].payeeId);
      },
      sort: (final Alias a, final Alias b, final bool sortAscending) {
        return sortByString(Payees.getNameFromId(a.payeeId),
            Payees.getNameFromId(b.payeeId), sortAscending);
      },
    );
  }

  FieldDefinition<Alias> getFieldForPattern() {
    return FieldDefinition<Alias>(
      name: 'Pattern',
      type: FieldType.text,
      align: TextAlign.left,
      value: (final int index) {
        return list[index].name;
      },
      sort: (final Alias a, final Alias b, final bool sortAscending) {
        return sortByString(a.name, b.name, sortAscending);
      },
    );
  }

  FieldDefinition<Alias> getFieldForType() {
    return FieldDefinition<Alias>(
      name: 'Type',
      type: FieldType.text,
      align: TextAlign.left,
      value: (final int index) {
        return list[index].type.toString();
      },
      sort: (final Alias a, final Alias b, final bool sortAscending) {
        return sortByString(
            a.type.toString(), b.type.toString(), sortAscending);
      },
    );
  }

  @override
  FieldDefinitions<Alias> getFieldDefinitionsForTable() {
    return FieldDefinitions<Alias>(list: <FieldDefinition<Alias>>[
      getFieldForPayee(),
      getFieldForPattern(),
      getFieldForType(),
    ]);
  }

  @override
  FieldDefinitions<Alias> getFieldDefinitionsForDetailsPanel() {
    final FieldDefinitions<Alias> fields =
        FieldDefinitions<Alias>(list: <FieldDefinition<Alias>>[
      getFieldForPattern(),
      getFieldForType(),
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
    final Alias? alias = getFirstElement<Alias>(indices, list);
    if (alias != null && alias.id > -1) {
      final Payee payee = alias.payee;
      return ViewTransactions(
        key: Key(payee.id.toString()),
        filter: (final Transaction transaction) =>
            transaction.payeeId == payee.id,
        preference: preferenceJustTableDatePayeeCategoryAmountBalance,
        startingBalance: 0,
      );
    }
    return const Text('No transactions');
  }
}
