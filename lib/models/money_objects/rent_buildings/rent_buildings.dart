import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/rent_buildings/rent_building.dart';
import 'package:money/models/money_objects/rental_unit/rental_unit.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

class RentBuildings extends MoneyObjects<RentBuilding> {
  RentBuildings() {
    collectionName = 'Rental Buildings';
  }

  String getNameFromId(final int id) {
    final RentBuilding? found = get(id);
    if (found == null) {
      return id.toString();
    }
    return found.name.value;
  }

  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();

    for (final MyJson row in rows) {
      appendMoneyObject(RentBuilding.fromJson(row));
    }
  }

  @override
  void loadDemoData() {
    clear();

    final RentBuilding instance = RentBuilding();
    instance.id.value = 0;
    instance.name.value = 'AirBnB';
    instance.address.value = 'One Washington DC';
    appendMoneyObject(instance);
  }

  @override
  void onAllDataLoaded() {
    for (final RentBuilding rental in iterableList(includeDeleted: true)) {
      rental.associateAccountToBuilding();
      cumulateTransactions(rental);

      for (final RentUnit unit in Data().rentUnits.iterableList()) {
        if (unit.building.value == rental.id.value) {
          rental.units.add(unit);
        }
      }
    }
  }

  void cumulateTransactions(final RentBuilding rental) {
    for (Transaction t in Data().transactions.iterableList()) {
      rental.cumulatePnL(t);
    }
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }
}
