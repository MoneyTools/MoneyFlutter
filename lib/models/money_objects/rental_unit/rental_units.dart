import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/rental_unit/rental_unit.dart';

class RentUnits extends MoneyObjects<RentUnit> {
  String getNameFromId(final int id) {
    final RentUnit? found = get(id);
    if (found == null) {
      return id.toString();
    }
    return found.name;
  }

  @override
  void loadFromJson(final List<MyJson> rows) {
    for (final MyJson row in rows) {
      addEntry(RentUnit.fromSqlite(row));
    }
  }
}
