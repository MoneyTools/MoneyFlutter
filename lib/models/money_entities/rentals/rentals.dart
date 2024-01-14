import 'package:money/helpers/json_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_entities/money_entity.dart';
import 'package:money/models/money_entities/rentals/rental.dart';
import 'package:money/models/money_entities/rentals/rental_unit/rental_unit.dart';
import 'package:money/models/money_entities/transactions/transaction.dart';

class Rentals {
  MoneyObjects<Rental> moneyObjects = MoneyObjects<Rental>();

  Rental? get(final int id) {
    return moneyObjects.get(id);
  }

  String getNameFromId(final int id) {
    final Rental? found = get(id);
    if (found == null) {
      return id.toString();
    }
    return found.name;
  }

  void clear() {
    moneyObjects.clear();
  }

  load(final List<Json> rows) {
    clear();

    for (final Json row in rows) {
      moneyObjects.addEntry(Rental.fromSqlite(row));
    }
  }

  void loadDemoData() {
    clear();

    final Rental instance = Rental(id: 0, name: 'AirBnB');
    instance.address = 'One Washington DC';
    moneyObjects.addEntry(instance);
  }

  onAllDataLoaded() {
    final List<RentUnit> allUnits = Data().rentUnits.moneyObjects.getAsList();

    for (final Rental rental in moneyObjects.getAsList()) {
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

  cumulateTransactions(final Rental rental) {
    for (Transaction t in Data().transactions.list) {
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
}
