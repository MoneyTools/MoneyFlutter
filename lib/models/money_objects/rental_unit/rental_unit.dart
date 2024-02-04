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
class RentUnit extends MoneyObject {
  @override
  int get uniqueId => id.value;
  @override
  set uniqueId(value) => id.value = value;

  /// Id
  /// 0|Id|INT|0||1
  FieldInt<RentUnit> id = FieldInt<RentUnit>(
    importance: 0,
    serializeName: 'Id',
    useAsColumn: false,
    valueForSerialization: (final RentUnit instance) => instance.id.value,
  );

  /// Building Id
  /// 1|Building|INT|1||0
  FieldInt<RentUnit> building = FieldInt<RentUnit>(
    importance: 1,
    name: 'Building',
    serializeName: 'Building',
    useAsColumn: false,
    valueForSerialization: (final RentUnit instance) => instance.building.value,
  );

  /// 2
  /// 2|Name|nvarchar(255)|1||0
  FieldString<RentUnit> name = FieldString<RentUnit>(
    importance: 2,
    name: 'Name',
    serializeName: 'Name',
    valueForSerialization: (final RentUnit instance) => instance.name.value,
  );

  /// 3
  /// 3|Renter|nvarchar(255)|0||0
  FieldString<RentUnit> renter = FieldString<RentUnit>(
    importance: 3,
    name: 'Renter',
    serializeName: 'Renter',
    valueForSerialization: (final RentUnit instance) => instance.renter.value,
  );

  /// 4
  /// 4|Note|nvarchar(255)|0||0
  FieldString<RentUnit> note = FieldString<RentUnit>(
    importance: 4,
    name: 'Note',
    serializeName: 'Note',
    valueForSerialization: (final RentUnit instance) => instance.note.value,
  );

  // not persisted field
  int count = 0;
  double balance = 0.00;

  RentUnit();

  factory RentUnit.fromJson(final MyJson row) {
    return RentUnit()
      ..id.value = row.getInt('Id')
      ..name.value = row.getString('Name')
      ..building.value = row.getInt('Building', -1)
      ..renter.value = row.getString('Renter')
      ..note.value = row.getString('Note');
  }
}
