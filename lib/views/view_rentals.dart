import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/money_entity.dart';

import 'package:money/models/categories.dart';
import 'package:money/models/rentals.dart';
import 'package:money/models/splits.dart';
import 'package:money/models/transactions.dart';
import 'package:money/widgets/fields/field.dart';
import 'package:money/widgets/fields/fields.dart';
import 'package:money/widgets/chart.dart';
import 'package:money/views/view.dart';
import 'package:money/views/view_transactions.dart';

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
      value: (final int index) {
        return list[index].name;
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
      value: (final int index) {
        return list[index].address;
      },
      sort: (final MoneyEntity a, final MoneyEntity b, final bool sortAscending) {
        return sortByString((a as Rental).address, (b as Rental).address, sortAscending);
      },
    );
  }

  FieldDefinition<Rental> getColumnForNote() {
    return FieldDefinition<Rental>(
      name: 'Note',
      type: FieldType.text,
      align: TextAlign.left,
      value: (final int index) {
        return list[index].note;
      },
      sort: (final MoneyEntity a, final MoneyEntity b, final bool sortAscending) {
        return sortByString((a as Rental).note, (b as Rental).note, sortAscending);
      },
    );
  }

  @override
  FieldDefinitions<Rental> getFieldDefinitionsForTable() {
    return FieldDefinitions<Rental>(list: <FieldDefinition<Rental>>[
      getColumnForName(),
      getColumnForAddress(),
      getColumnForNote(),
      FieldDefinition<Rental>(
        name: 'In Service',
        type: FieldType.text,
        align: TextAlign.left,
        value: (final int index) {
          return (list[index]).dateRange.toStringYears();
        },
        sort: (final Rental a, final Rental b, final bool sortAscending) {
          return sortByString(a.dateRange.toString(), b.dateRange.toString(), sortAscending);
        },
      ),
      FieldDefinition<Rental>(
        name: 'Transactions',
        type: FieldType.numeric,
        align: TextAlign.right,
        value: (final int index) {
          return list[index].count;
        },
        sort: (final Rental a, final Rental b, final bool sortAscending) {
          return sortByValue(a.count, b.count, sortAscending);
        },
      ),
      FieldDefinition<Rental>(
        name: 'Revenue',
        type: FieldType.amountShorthand,
        align: TextAlign.right,
        value: (final int index) {
          return (list[index]).revenue;
        },
        sort: (final Rental a, final Rental b, final bool sortAscending) {
          return sortByValue(a.revenue, b.revenue, sortAscending);
        },
      ),
      FieldDefinition<Rental>(
        name: 'Expense',
        type: FieldType.amountShorthand,
        align: TextAlign.right,
        value: (final int index) {
          return (list[index]).expense;
        },
        sort: (final Rental a, final Rental b, final bool sortAscending) {
          return sortByValue(a.expense, b.expense, sortAscending);
        },
      ),
      FieldDefinition<Rental>(
        name: 'Profit',
        type: FieldType.amountShorthand,
        align: TextAlign.right,
        value: (final int index) {
          return list[index].profit;
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
        list: <FieldDefinition<Rental>>[getColumnForName(), getColumnForAddress(), getColumnForNote()]);

    final FieldDefinition<Rental> fieldUnit = FieldDefinition<Rental>(
      name: 'Unit',
      type: FieldType.amount,
      align: TextAlign.right,
      isMultiLine: true,
      value: (final int index) {
        return getUnitsAsString((list[index]).units);
      },
      sort: (final MoneyEntity a, final MoneyEntity b, final bool ascending) {
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
    return Rentals.moneyObjects.getAsList();
  }

  @override
  getDefaultSortColumn() {
    return 0; // Sort by name
  }

  @override
  Widget getSubViewContentForChart(final List<int> indices) {
    final List<PairXY> list = <PairXY>[];
    for (final Rental entry in getList()) {
      list.add(PairXY(entry.name, entry.profit));
    }

    return Chart(
      list: list,
      variableNameHorizontal: 'Rental',
      variableNameVertical: 'Profit',
    );
  }

  @override
  getSubViewContentForTransactions(final List<int> indices) {
    final Rental? rental = getFirstElement<Rental>(indices, list);
    if (rental != null) {
      return ViewTransactions(
        key: Key(rental.id.toString()),
        filter: (final Transaction t) => filterByRentalCategories(t, rental),
        preference: preferenceJustTableDatePayeeCategoryAmountBalance,
      );
    }
    return const Text('No transactions');
  }

  bool filterByRentalCategories(final Transaction t, final Rental rental) {
    final num categoryIdToMatch = t.categoryId;

    if (categoryIdToMatch == Categories.splitCategoryId()) {
      final List<Split> splits = Splits.get(t.id);

      for (final Split split in splits) {
        if (isMatchingCategories(split.categoryId, rental)) {
          return true;
        }
      }
      return false;
    }

    return isMatchingCategories(categoryIdToMatch, rental);
  }

  bool isMatchingCategories(final num categoryIdToMatch, final Rental rental) {
    Categories.getTreeIds(rental.categoryForIncome);

    return rental.categoryForIncomeTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForManagementTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForRepairsTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForMaintenanceTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForTaxesTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForInterestTreeIds.contains(categoryIdToMatch);
  }
}
