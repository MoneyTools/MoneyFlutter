import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/data/models/money_objects/money_object.dart';

/*
  SQLite table definition

  0|Id|INT|0||1
  1|Building|INT|1||0
  2|Name|nvarchar(255)|1||0
  3|Renter|nvarchar(255)|0||0
  4|Note|nvarchar(255)|0||0
 */
class RentUnit extends MoneyObject {
  RentUnit();

  factory RentUnit.fromJson(final MyJson row) {
    return RentUnit()
      ..id.value = row.getInt('Id', -1)
      ..name.value = row.getString('Name')
      ..building.value = row.getInt('Building', -1)
      ..renter.value = row.getString('Renter')
      ..note.value = row.getString('Note');
  }

  double balance = 0.00;

  /// Building Id
  /// 1|Building|INT|1||0
  FieldInt building = FieldInt(
    name: 'Building',
    serializeName: 'Building',
    getValueForSerialization: (final MoneyObject instance) => (instance as RentUnit).building.value,
  );

  // not persisted field
  int count = 0;

  /// Id
  /// 0|Id|INT|0||1
  FieldId id = FieldId(
    getValueForSerialization: (final MoneyObject instance) => instance.uniqueId,
  );

  /// 2
  /// 2|Name|nvarchar(255)|1||0
  FieldString name = FieldString(
    name: 'Name',
    serializeName: 'Name',
    getValueForSerialization: (final MoneyObject instance) => (instance as RentUnit).name.value,
  );

  /// 4
  /// 4|Note|nvarchar(255)|0||0
  FieldString note = FieldString(
    name: 'Note',
    serializeName: 'Note',
    getValueForSerialization: (final MoneyObject instance) => (instance as RentUnit).note.value,
  );

  /// 3
  /// 3|Renter|nvarchar(255)|0||0
  FieldString renter = FieldString(
    name: 'Renter',
    serializeName: 'Renter',
    getValueForSerialization: (final MoneyObject instance) => (instance as RentUnit).renter.value,
  );

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;
}
