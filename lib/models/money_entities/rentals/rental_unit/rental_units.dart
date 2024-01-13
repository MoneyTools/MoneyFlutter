import 'package:money/models/money_entities/money_entity.dart';
import 'package:money/models/money_entities/rentals/rental.dart';
import 'package:money/models/money_entities/rentals/rental_unit/rental_unit.dart';

class RentUnits {
  MoneyObjects<RentUnit> moneyObjects = MoneyObjects<RentUnit>();

  RentUnit? get(final int id) {
    return moneyObjects.get(id);
  }

  String getNameFromId(final int id) {
    final RentUnit? found = get(id);
    if (found == null) {
      return id.toString();
    }
    return found.name;
  }

  load(final List<Map<String, Object?>> rows) async {
    for (final Map<String, Object?> row in rows) {
      final int id = int.parse(row['Id'].toString());
      final String name = row['Name'].toString();

      final RentUnit instance = RentUnit(id, name);
      instance.building = row['Building'].toString();
      instance.renter = row['Renter'].toString();
      instance.note = row['Note'].toString();

      moneyObjects.addEntry(instance);
    }
  }

  loadDemoData() {}

  onAllDataLoaded() {
    for (RentUnit item in moneyObjects.getAsList()) {
      final Rental a = item as Rental;
      a.count = 0;
      a.revenue = 0;
    }

    // for (var t in Transactions.list) {
    //   // var item = get(t.accountId);
    //   // if (item != null) {
    //   //   item.count++;
    //   //   item.balance += t.amount;
    //   // }
    // }
  }
}
