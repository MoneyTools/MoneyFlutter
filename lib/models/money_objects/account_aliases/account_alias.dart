import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';

/*

  0    Id         INT            0                    1
  1    Pattern    nvarchar(255)  1                    0
  2    Flags      INT            1                    0
  3    AccountId  nchar(20)      1                    0

 */
class AccountAlias extends MoneyObject {
  // 0
  // int MoneyEntity.Id

  // 1
  final String pattern;
  final int flags;
  final String accountId;

  AccountAlias({
    required super.id,
    required this.pattern,
    required this.flags,
    required this.accountId,
  });

  /// Constructor from a SQLite row
  factory AccountAlias.fromSqlite(final Json row) {
    return AccountAlias(
      // 0
      id: jsonGetInt(row, 'Id'),
      // 1
      pattern: jsonGetString(row, 'Pattern'),
      // 2
      flags: jsonGetInt(row, 'Flags'),
      // 3
      accountId: jsonGetString(row, 'AccountId'),
    );
  }

  static FieldDefinition<AccountAlias> getFieldForFlags() {
    return FieldDefinition<AccountAlias>(
      type: FieldType.numeric,
      name: 'Flags',
      serializeName: 'Flags',
      align: TextAlign.left,
      valueFromInstance: (final AccountAlias item) {
        return item.flags;
      },
      valueForSerialization: (final AccountAlias item) {
        return item.flags;
      },
      sort: (final AccountAlias a, final AccountAlias b, final bool sortAscending) {
        return sortByValue(a.flags, b.flags, sortAscending);
      },
    );
  }

  static FieldDefinition<AccountAlias> getFieldForPattern() {
    return FieldDefinition<AccountAlias>(
      type: FieldType.text,
      name: 'Pattern',
      serializeName: 'pattern',
      align: TextAlign.left,
      valueFromInstance: (final AccountAlias item) {
        return item.pattern;
      },
      sort: (final AccountAlias a, final AccountAlias b, final bool sortAscending) {
        return sortByString(a.pattern, b.pattern, sortAscending);
      },
    );
  }
}

enum AccountAliasType {
  none, // 0
  regex, // 1
}
