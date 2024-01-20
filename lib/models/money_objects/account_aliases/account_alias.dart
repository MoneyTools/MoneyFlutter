import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';

/*

  0    Id         INT            0                    1
  1    Pattern    nvarchar(255)  1                    0
  2    Flags      INT            1                    0
  3    AccountId  nchar(20)      1                    0

 */
class AccountAlias extends MoneyObject<AccountAlias> {
  // 0
  Declare<AccountAlias, int> id = Declare<AccountAlias, int>(
    importance: 0,
    serializeName: 'Id',
    defaultValue: -1,
    useAsColumn: false,
    valueForSerialization: (final AccountAlias instance) => instance.id.value,
  );

  // 1
  Declare<AccountAlias, String> pattern = Declare<AccountAlias, String>(
    importance: 1,
    serializeName: 'Pattern',
    defaultValue: '',
  );

  // 2
  Declare<AccountAlias, int> flags = Declare<AccountAlias, int>(
    importance: 2,
    serializeName: 'Flags',
    defaultValue: 0,
  );

  // 3
  Declare<AccountAlias, String> accountId = Declare<AccountAlias, String>(
    importance: 3,
    serializeName: 'AccountId',
    defaultValue: '',
  );

  AccountAlias();

  @override
  int get uniqueId => id.value;

  /// Constructor from a SQLite row
  factory AccountAlias.fromSqlite(final Json row) {
    return AccountAlias()
      ..id.value = jsonGetInt(row, 'Id')
      ..pattern.value = jsonGetString(row, 'Pattern')
      ..flags.value = jsonGetInt(row, 'Flag')
      ..accountId.value = jsonGetString(row, 'AccountId');
  }
}

enum AccountAliasType {
  none, // 0
  regex, // 1
}
