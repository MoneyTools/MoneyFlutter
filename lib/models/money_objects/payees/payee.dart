import 'package:money/models/money_objects/money_object.dart';

/*
  SQLite table definition

  0|Id|INT|0||1
  1|Name|nvarchar(255)|1||0
 */
class Payee extends MoneyObject<Payee> {
  @override
  int get uniqueId => id.value;

  // 0
  Declare<Payee, int> id = Declare<Payee, int>(
    importance: 0,
    serializeName: 'Id',
    defaultValue: -1,
    useAsColumn: false,
    valueForSerialization: (final Payee instance) => instance.id.value,
  );

  // 1
  Declare<Payee, String> name = Declare<Payee, String>(
    importance: 1,
    name: 'Name',
    serializeName: 'Name',
    defaultValue: '',
    valueFromInstance: (final Payee instance) => instance.name.value,
    valueForSerialization: (final Payee instance) => instance.name.value,
  );

  Declare<Payee, int> count = DeclareNoSerialized<Payee, int>(
    type: FieldType.numeric,
    name: 'Count',
    defaultValue: 0,
    align: TextAlign.right,
    valueFromInstance: (final Payee instance) => instance.count.value,
    valueForSerialization: (final Payee instance) => instance.count.value,
  );

  Declare<Payee, double> balance = DeclareNoSerialized<Payee, double>(
    type: FieldType.amount,
    name: 'Balance',
    defaultValue: 0,
    align: TextAlign.right,
    valueFromInstance: (final Payee instance) => instance.balance.value,
    valueForSerialization: (final Payee instance) => instance.balance.value,
  );

  Payee();

  static getName(final Payee? payee) {
    return payee == null ? '' : payee.name.value;
  }
}
