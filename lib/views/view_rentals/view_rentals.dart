import 'package:flutter/material.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/money_object.dart';

import 'package:money/models/money_objects/rentals/rental.dart';
import 'package:money/models/money_objects/rentals/rental_unit/rental_unit.dart';
import 'package:money/models/money_objects/splits/splits.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

import 'package:money/widgets/chart.dart';
import 'package:money/views/view.dart';
import 'package:money/widgets/table_view/table_transactions.dart';

part 'view_rentals_details_panels.dart';

class ViewRentals extends ViewWidget<Rental> {
  const ViewRentals({super.key});

  @override
  State<ViewWidget<Rental>> createState() => ViewRentalsState();
}

class ViewRentalsState extends ViewWidgetState<Rental> {
  @override
  getClassNamePlural() {
    return 'Rentals';
  }

  @override
  getClassNameSingular() {
    return 'Rental';
  }

  @override
  String getDescription() {
    return 'Properties to rent.';
  }

  FieldDefinition<Rental> getColumnForName() {
    return FieldDefinition<Rental>(
      name: 'Name',
      type: FieldType.text,
      align: TextAlign.left,
      valueFromInstance: (final Rental rental) {
        return rental.name;
      },
      sort: (final Rental a, final Rental b, final bool sortAscending) {
        return sortByString(a.name, b.name, sortAscending);
      },
    );
  }

  FieldDefinition<Rental> getColumnForAddress() {
    return FieldDefinition<Rental>(
      name: 'Address',
      type: FieldType.text,
      align: TextAlign.left,
      valueFromInstance: (final Rental rental) {
        return rental.address;
      },
      sort: (final Rental a, final Rental b, final bool sortAscending) {
        return sortByString(a.address, b.address, sortAscending);
      },
    );
  }

  FieldDefinition<Rental> getColumnForNote() {
    return FieldDefinition<Rental>(
      name: 'Note',
      type: FieldType.text,
      align: TextAlign.left,
      valueFromInstance: (final Rental rental) {
        return rental.note;
      },
      sort: (final Rental a, final Rental b, final bool sortAscending) {
        return sortByString(a.note, b.note, sortAscending);
      },
    );
  }

  @override
  FieldDefinitions<Rental> getFieldDefinitionsForTable() {
    return FieldDefinitions<Rental>(definitions: <FieldDefinition<Rental>>[
      getColumnForName(),
      getColumnForAddress(),
      getColumnForNote(),
      FieldDefinition<Rental>(
        name: 'In Service',
        type: FieldType.text,
        align: TextAlign.left,
        valueFromInstance: (final Rental rental) {
          return rental.dateRange.toStringYears();
        },
        sort: (final Rental a, final Rental b, final bool sortAscending) {
          return sortByString(a.dateRange.toString(), b.dateRange.toString(), sortAscending);
        },
      ),
      FieldDefinition<Rental>(
        name: 'Transactions',
        type: FieldType.numeric,
        align: TextAlign.right,
        valueFromInstance: (final Rental rental) {
          return rental.count;
        },
        sort: (final Rental a, final Rental b, final bool sortAscending) {
          return sortByValue(a.count, b.count, sortAscending);
        },
      ),
      FieldDefinition<Rental>(
        name: 'Revenue',
        type: FieldType.amountShorthand,
        align: TextAlign.right,
        valueFromInstance: (final Rental rental) {
          return rental.revenue;
        },
        sort: (final Rental a, final Rental b, final bool sortAscending) {
          return sortByValue(a.revenue, b.revenue, sortAscending);
        },
      ),
      FieldDefinition<Rental>(
        name: 'Expense',
        type: FieldType.amountShorthand,
        align: TextAlign.right,
        valueFromInstance: (final Rental rental) {
          return rental.expense;
        },
        sort: (final Rental a, final Rental b, final bool sortAscending) {
          return sortByValue(a.expense, b.expense, sortAscending);
        },
      ),
      FieldDefinition<Rental>(
        name: 'Profit',
        type: FieldType.amountShorthand,
        align: TextAlign.right,
        valueFromInstance: (final Rental rental) {
          return rental.profit;
        },
        sort: (final Rental a, final Rental b, final bool sortAscending) {
          return sortByValue(a.profit, b.profit, sortAscending);
        },
      )
    ]);
  }

  @override
  FieldDefinitions<Rental> getFieldDefinitionsForDetailsPanel() {
    final FieldDefinitions<Rental> fields = FieldDefinitions<Rental>(
        definitions: <FieldDefinition<Rental>>[getColumnForName(), getColumnForAddress(), getColumnForNote()]);

    final FieldDefinition<Rental> fieldUnit = FieldDefinition<Rental>(
      name: 'Unit',
      type: FieldType.amount,
      align: TextAlign.right,
      isMultiLine: true,
      valueFromInstance: (final Rental rental) {
        return getUnitsAsString(rental.units);
      },
      sort: (final MoneyObject a, final MoneyObject b, final bool ascending) {
        return sortByValue((a as Rental).revenue, (b as Rental).revenue, sortAscending);
      },
    );

    fields.add(fieldUnit);

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
  List<Rental> getList() {
    return Data().rentals.moneyObjects.getAsList();
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
