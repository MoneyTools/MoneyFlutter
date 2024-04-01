import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';

/*

  0    Id         INT            0                    1
  1    Pattern    nvarchar(255)  1                    0
  2    Flags      INT            1                    0
  3    AccountId  nchar(20)      1                    0

 */
class AccountAlias extends MoneyObject {
  static Fields<AccountAlias>? fields;

  @override
  String getRepresentation() {
    return '${pattern.value} ${accountId.value}';
  }

  // 0
  Field<int> id = Field<int>(
    importance: 0,
    serializeName: 'Id',
    defaultValue: -1,
    useAsColumn: false,
    valueForSerialization: (final MoneyObject instance) => (instance as AccountAlias).uniqueId,
  );

  // 1
  Field<String> pattern = Field<String>(
    importance: 1,
    serializeName: 'Pattern',
    defaultValue: '',
  );

  // 2
  Field<int> flags = Field<int>(
    importance: 2,
    serializeName: 'Flags',
    defaultValue: 0,
  );

  // 3
  Field<String> accountId = Field<String>(
    importance: 3,
    serializeName: 'AccountId',
    defaultValue: '',
  );

  AccountAlias() {
    fields ??= Fields<AccountAlias>(definitions: [
      id,
      pattern,
      flags,
      accountId,
    ]);
    // Also stash the definition in the instance for fast retrieval later
    fieldDefinitions = fields!.definitions;
  }

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  /// Constructor from a SQLite row
  @override
  factory AccountAlias.fromJson(final MyJson row) {
    return AccountAlias()
      ..id.value = row.getInt('Id', -1)
      ..pattern.value = row.getString('Pattern')
      ..flags.value = row.getInt('Flag', 0)
      ..accountId.value = row.getString('AccountId');
  }
}
