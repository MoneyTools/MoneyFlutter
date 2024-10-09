import 'package:money/data/models/money_objects/rent_buildings/rent_building.dart';
import 'package:money/data/models/money_objects/rental_unit/rental_unit.dart';
import 'package:money/data/models/money_objects/transactions/transaction.dart';
import 'package:money/data/storage/data/data.dart';

class RentBuildings extends MoneyObjects<RentBuilding> {
  RentBuildings() {
    collectionName = 'Rental Buildings';
  }

  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();

    for (final MyJson row in rows) {
      appendMoneyObject(RentBuilding.fromJson(row));
    }
  }

  @override
  void onAllDataLoaded() {
    for (final RentBuilding rental in iterableList(includeDeleted: true)) {
      rental.associateAccountToBuilding();
      cumulateTransactions(rental);

      for (final RentUnit unit in Data().rentUnits.iterableList()) {
        if (unit.fieldBuilding.value == rental.fieldId.value) {
          rental.units.add(unit);
        }
      }
    }
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }

  void cumulateTransactions(final RentBuilding rental) {
    for (Transaction t in Data().transactions.iterableList()) {
      rental.cumulatePnL(t);
    }
  }
}
