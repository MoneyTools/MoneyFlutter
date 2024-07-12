import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/rental_unit/rental_unit.dart';

class RentUnits extends MoneyObjects<RentUnit> {
  RentUnits() {
    collectionName = 'Rental Units';
  }

  @override
  void loadFromJson(final List<MyJson> rows) {
    for (final MyJson row in rows) {
      appendMoneyObject(RentUnit.fromJson(row));
    }
  }

  String getNameFromId(final int id) {
    final RentUnit? found = get(id);
    if (found == null) {
      return '';
    }
    return found.name.value;
  }
}
