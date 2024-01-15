import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/rentals/rental.dart';
import 'package:money/models/money_objects/rentals/rental_unit/rental_unit.dart';

class RentUnits extends MoneyObjects<RentUnit> {
  String getNameFromId(final int id) {
    final RentUnit? found = get(id);
    if (found == null) {
      return id.toString();
    }
    return found.name;
  }

  load(final List<Json> rows) async {
    for (final Json row in rows) {
      addEntry(RentUnit.fromSqlite(row));
    }
  }

  loadDemoData() {}

  onAllDataLoaded() {
    for (RentUnit item in getList()) {
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
