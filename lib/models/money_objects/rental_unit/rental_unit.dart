import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_object.dart';

/*
  SQLite table definition

  0|Id|INT|0||1
  1|Building|INT|1||0
  2|Name|nvarchar(255)|1||0
  3|Renter|nvarchar(255)|0||0
  4|Note|nvarchar(255)|0||0
 */
class RentUnit extends MoneyObject<RentUnit> {
  @override
  int get uniqueId => id.value;

  // 0
  Field<RentUnit, int> id = Field<RentUnit, int>(
    importance: 0,
    serializeName: 'Id',
    defaultValue: -1,
    useAsColumn: false,
    valueForSerialization: (final RentUnit instance) => instance.id.value,
  );

  // 1
  String name;

  // 2
  int building;

  // 3
  String renter = '';

  // 4
  String note = '';

  // not persisted field
  int count = 0;
  double balance = 0.00;

  RentUnit({
    required this.name,
    required this.building,
    required this.renter,
    required this.note,
  });

  factory RentUnit.fromSqlite(final MyJson row) {
    return RentUnit(
      name: row.getString('Name'),
      building: row.getInt('Building', -1),
      renter: row.getString('Renter'),
      note: row.getString('Note'),
    )..id.value = row.getInt('Id');
  }
}
