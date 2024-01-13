import 'package:money/models/money_entities/money_entity.dart';

class RentUnit extends MoneyEntity {
  int count = 0;
  double balance = 0.00;
  String building = '';
  String renter = '';
  String note = '';

  RentUnit(super.id, super.name);
}
