import 'package:money/core/helpers/json_helper.dart';
import 'package:money/data/models/money_objects/money_objects.dart';
import 'package:money/data/models/money_objects/rental_unit/rental_unit.dart';

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
}
