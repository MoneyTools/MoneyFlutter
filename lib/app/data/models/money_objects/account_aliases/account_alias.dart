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
      ..fieldId.value = row.getInt('Id', -1)
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

  FieldId fieldId = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as AccountAlias).uniqueId,
  );

  FieldString fieldPattern = FieldString(
    serializeName: 'Pattern',
  );

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions {
    final tmp = AccountAlias.fromJson({});
    final f = Fields<AccountAlias>()
      ..setDefinitions([
        tmp.fieldId,
        tmp.fieldPattern,
        tmp.fieldFlags,
        tmp.fieldAccountId,
      ]);
    return f.definitions;
  }

  @override
  String getRepresentation() {
    return '${fieldPattern.value} ${fieldAccountId.value}';
  }

  @override
  int get uniqueId => fieldId.value;

  @override
  set uniqueId(value) => fieldId.value = value;

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
