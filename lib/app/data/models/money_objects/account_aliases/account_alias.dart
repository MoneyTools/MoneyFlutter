import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';

/*

  0    Id         INT            0                    1
  1    Pattern    nvarchar(255)  1                    0
  2    Flags      INT            1                    0
  3    AccountId  nchar(20)      1                    0

 */
class AccountAlias extends MoneyObject {
  static final _fields = Fields<AccountAlias>();

  static get fields {
    if (_fields.isEmpty) {
      final tmp = AccountAlias.fromJson({});
      _fields.setDefinitions(
        [
          tmp.id,
          tmp.pattern,
          tmp.flags,
          tmp.accountId,
        ],
      );
    }
  }

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
    getValueForSerialization: (final MoneyObject instance) => (instance as AccountAlias).uniqueId,
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

  /// Constructor
  AccountAlias() {
    // body
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
