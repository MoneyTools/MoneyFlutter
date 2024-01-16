import 'package:money/helpers/json_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/rentals/rent_buildings/rent_building.dart';
import 'package:money/models/money_objects/rentals/rental_unit/rental_unit.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

class RentBuildings extends MoneyObjects<RentBuilding> {
  String getNameFromId(final int id) {
    final RentBuilding? found = get(id);
    if (found == null) {
      return id.toString();
    }
    return found.name;
  }

  load(final List<Json> rows) {
    clear();

    for (final Json row in rows) {
      addEntry(RentBuilding.fromSqlite(row));
    }
  }

  void loadDemoData() {
    clear();

    final RentBuilding instance = RentBuilding(id: 0, name: 'AirBnB');
    instance.address = 'One Washington DC';
    addEntry(instance);
  }

  onAllDataLoaded() {
    final List<RentUnit> allUnits = Data().rentUnits.getList();

    for (final RentBuilding rental in getList()) {
      cumulateTransactions(rental);

      // expense is a negative number so we just do a Revenue + Expense
      rental.profit = rental.revenue + rental.expense;

      for (final RentUnit unit in allUnits) {
        if (unit.building == rental.id.toString()) {
          rental.units.add(unit);
        }
      }
    }
  }

  cumulateTransactions(final RentBuilding rental) {
    for (Transaction t in Data().transactions.getList()) {
      if (rental.categoryForIncomeTreeIds.contains(t.categoryId)) {
        rental.dateRange.inflate(t.dateTime);
        rental.count++;
        rental.revenue += t.amount;
      } else {
        // if (listOfCategoryIdsExpenses.contains(t.categoryId)) {
        //   rental.dateRange.inflate(t.dateTime);
        //   rental.count++;
        //   rental.expense += t.amount;
        // }
      }
    }
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      RentBuilding.getFieldDefinitions(),
      getListSortedById(),
    );
  }
}
