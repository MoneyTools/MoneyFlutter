import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';

/*

  0    Id         INT            0                    1
  1    Pattern    nvarchar(255)  1                    0
  2    Flags      INT            1                    0
  3    AccountId  nchar(20)      1                    0

 */
class AccountAlias extends MoneyObject {
  /// Constructor
  AccountAlias() {
    // body
  }

  /// Constructor from a SQLite row
  @override
  factory AccountAlias.fromJson(final MyJson row) {
    return AccountAlias()
      ..id.value = row.getInt('Id', -1)
      ..fieldPattern.value = row.getString('Pattern')
      ..fieldFlags.value = row.getInt('Flag', 0)
      ..fieldAccountId.value = row.getString('AccountId');
  }

  FieldString fieldAccountId = FieldString(
    serializeName: 'AccountId',
  );

  FieldInt fieldFlags = FieldInt(
    serializeName: 'Flags',
    defaultValue: 0,
  );

  FieldString fieldPattern = FieldString(
    serializeName: 'Pattern',
  );

  FieldInt id = FieldInt(
    serializeName: 'Id',
    getValueForSerialization: (final MoneyObject instance) => (instance as AccountAlias).uniqueId,
  );

  @override
  String getRepresentation() {
    return '${fieldPattern.value} ${fieldAccountId.value}';
  }

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  static final _fields = Fields<AccountAlias>();

  static Fields<AccountAlias> get fieldsForColumnView {
    if (_fields.isEmpty) {
      final tmp = AccountAlias.fromJson({});
      _fields.setDefinitions(
        [
          tmp.fieldPattern,
          tmp.fieldFlags,
          tmp.fieldAccountId,
        ],
      );
    }
    return _fields;
  }
}
