import 'package:flutter/material.dart';
import 'package:money/helpers.dart';

import '../models/rentals.dart';
import '../models/transactions.dart';
import '../widgets/columns.dart';
import '../widgets/widget_bar_chart.dart';
import '../widgets/widget_view.dart';
import 'view_transactions.dart';

class ViewRentals extends ViewWidget {
  const ViewRentals({super.key});

  @override
  State<ViewWidget> createState() => ViewRentalsState();
}

class ViewRentalsState extends ViewWidgetState {
  @override
  getClassNamePlural() {
    return "Rentals";
  }

  @override
  getClassNameSingular() {
    return "Rental";
  }

  @override
  String getDescription() {
    return "Properties to rent.";
  }

  getColumnForName() {
    return ColumnDefinition(
      "Name",
      ColumnType.text,
      TextAlign.left,
      (index) {
        return list[index].name;
      },
      (a, b, sortAscending) {
        return sortByString(a.name, b.name, sortAscending);
      },
    );
  }

  getColumnForAddress() {
    return ColumnDefinition(
      "Address",
      ColumnType.text,
      TextAlign.left,
      (index) {
        return list[index].address;
      },
      (a, b, sortAscending) {
        return sortByString(a.address, b.address, sortAscending);
      },
    );
  }

  getColumnForNote() {
    return ColumnDefinition(
      "Note",
      ColumnType.text,
      TextAlign.left,
      (index) {
        return list[index].note;
      },
      (a, b, sortAscending) {
        return sortByString(a.note, b.note, sortAscending);
      },
    );
  }

  @override
  ColumnDefinitions getColumnDefinitionsForTable() {
    return ColumnDefinitions([
      getColumnForName(),
      getColumnForAddress(),
      getColumnForNote(),
      ColumnDefinition(
        "In Service",
        ColumnType.text,
        TextAlign.left,
        (index) {
          return list[index].dateRange.toStringYears();
        },
        (Rental a, Rental b, sortAscending) {
          return sortByString(a.dateRange.toString(), b.dateRange.toString(), sortAscending);
        },
      ),
      ColumnDefinition(
        "Transactions",
        ColumnType.numeric,
        TextAlign.right,
        (index) {
          return list[index].count;
        },
        (a, b, sortAscending) {
          return sortByValue(a.count, b.count, sortAscending);
        },
      ),
      ColumnDefinition(
        "Revenue",
        ColumnType.amountShorthand,
        TextAlign.right,
        (index) {
          return list[index].revenue;
        },
        (a, b, sortAscending) {
          return sortByValue(a.revenue, b.revenue, sortAscending);
        },
      ),
      ColumnDefinition(
        "Expense",
        ColumnType.amountShorthand,
        TextAlign.right,
        (index) {
          return list[index].expense;
        },
        (a, b, sortAscending) {
          return sortByValue(a.expense, b.expense, sortAscending);
        },
      ),
      ColumnDefinition(
        "Profit",
        ColumnType.amountShorthand,
        TextAlign.right,
        (index) {
          return list[index].profit;
        },
        (a, b, sortAscending) {
          return sortByValue(a.profit, b.profit, sortAscending);
        },
      )
    ]);
  }

  @override
  ColumnDefinitions getColumnDefinitionsForDetailsPanel() {
    var fields = ColumnDefinitions([getColumnForName(), getColumnForAddress(), getColumnForNote()]);

    var fieldUnit = ColumnDefinition(
      "Unit",
      ColumnType.amount,
      TextAlign.right,
      (index) {
        return getUnitsAsString(list[index].units);
      },
      (a, b, sortAscending) {
        return sortByValue(a.revenue, b.revenue, sortAscending);
      },
    );
    fieldUnit.isMultiLine = true;

    fields.add(fieldUnit);

    return fields;
  }

  getUnitsAsString(List<RentUnit> listOfUnits) {
    var listAsText = [];
    for (var unit in listOfUnits) {
      listAsText.add("${unit.name}:${unit.renter}");
    }

    return listAsText.join("\n");
  }

  @override
  getList() {
    return Rentals.moneyObjects.getAsList();
  }

  @override
  getDefaultSortColumn() {
    return 0; // Sort by name
  }

  @override
  getSubViewContentForChart(List<int> indices) {
    List<CategoryValue> list = [];
    for (var entry in getList()) {
      list.add(CategoryValue(entry.name, entry.profit));
    }

    return WidgetBarChart(list: list);
  }

  @override
  getSubViewContentForTransactions(List<int> indices) {
    var rental = getFirstElement<Rental>(indices, list);
    if (rental != null) {
      return ViewTransactions(
        key: Key(rental.id.toString()),
        filter: (dynamic t) => filterByRentalCategories(t, rental),
        preference: preferenceJustTableDatePayeeCategoryAmountBalance,
      );
    }
    return const Text("No transactions");
  }

  bool filterByRentalCategories(Transaction t, Rental rental) {
    return t.categoryId == rental.categoryForIncome ||
        t.categoryId == rental.categoryForInterest ||
        t.categoryId == rental.categoryForMaintenance ||
        t.categoryId == rental.categoryForManagement ||
        t.categoryId == rental.categoryForRepairs ||
        t.categoryId == rental.categoryForTaxes;
  }
}
