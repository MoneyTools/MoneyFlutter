import 'package:flutter/material.dart';
import 'package:money/helpers.dart';
import 'package:money/models/money_entity.dart';

import 'package:money/models/categories.dart';
import 'package:money/models/rentals.dart';
import 'package:money/models/splits.dart';
import 'package:money/models/transactions.dart';
import 'package:money/widgets/columns.dart';
import 'package:money/widgets/widget_bar_chart.dart';
import 'package:money/widgets/widget_view.dart';
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

  ColumnDefinition<Rental> getColumnForName() {
    return ColumnDefinition<Rental>(
      name: 'Name',
      type: ColumnType.text,
      align: TextAlign.left,
      value: (final int index) {
        return list[index].name;
      },
      sort: (final Rental a, final Rental b, final bool sortAscending) {
        return sortByString(a.name, b.name, sortAscending);
      },
    );
  }

  ColumnDefinition<Rental> getColumnForAddress() {
    return ColumnDefinition<Rental>(
      name: 'Address',
      type: ColumnType.text,
      align: TextAlign.left,
      value: (final int index) {
        return list[index].address;
      },
      sort: (final MoneyEntity a, final MoneyEntity b, final bool sortAscending) {
        return sortByString((a as Rental).address, (b as Rental).address, sortAscending);
      },
    );
  }

  ColumnDefinition<Rental> getColumnForNote() {
    return ColumnDefinition<Rental>(
      name: 'Note',
      type: ColumnType.text,
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
  ColumnDefinitions<Rental> getColumnDefinitionsForTable() {
    return ColumnDefinitions<Rental>(list: <ColumnDefinition<Rental>>[
      getColumnForName(),
      getColumnForAddress(),
      getColumnForNote(),
      ColumnDefinition<Rental>(
        name: 'In Service',
        type: ColumnType.text,
        align: TextAlign.left,
        value: (final int index) {
          return (list[index]).dateRange.toStringYears();
        },
        sort: (final Rental a, final Rental b, final bool sortAscending) {
          return sortByString(a.dateRange.toString(), b.dateRange.toString(), sortAscending);
        },
      ),
      ColumnDefinition<Rental>(
        name: 'Transactions',
        type: ColumnType.numeric,
        align: TextAlign.right,
        value: (final int index) {
          return list[index].count;
        },
        sort: (final Rental a, final Rental b, final bool sortAscending) {
          return sortByValue(a.count, b.count, sortAscending);
        },
      ),
      ColumnDefinition<Rental>(
        name: 'Revenue',
        type: ColumnType.amountShorthand,
        align: TextAlign.right,
        value: (final int index) {
          return (list[index]).revenue;
        },
        sort: (final Rental a, final Rental b, final bool sortAscending) {
          return sortByValue(a.revenue, b.revenue, sortAscending);
        },
      ),
      ColumnDefinition<Rental>(
        name: 'Expense',
        type: ColumnType.amountShorthand,
        align: TextAlign.right,
        value: (final int index) {
          return (list[index]).expense;
        },
        sort: (final Rental a, final Rental b, final bool sortAscending) {
          return sortByValue(a.expense, b.expense, sortAscending);
        },
      ),
      ColumnDefinition<Rental>(
        name: 'Profit',
        type: ColumnType.amountShorthand,
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
  ColumnDefinitions<Rental> getColumnDefinitionsForDetailsPanel() {
    final ColumnDefinitions<Rental> fields = ColumnDefinitions<Rental>(list: <ColumnDefinition<Rental>>[getColumnForName(), getColumnForAddress(), getColumnForNote()]);

    final ColumnDefinition<Rental> fieldUnit = ColumnDefinition<Rental>(
      name: 'Unit',
      type: ColumnType.amount,
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
  Widget getSubViewContentForChart(final List<num> indices) {
    final List<PairXY> list = <PairXY>[];
    for (final Rental entry in getList()) {
      list.add(PairXY(entry.name, entry.profit));
    }

    return WidgetBarChart(
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
