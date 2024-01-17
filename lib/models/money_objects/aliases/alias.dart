import 'package:money/helpers/json_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/payees/payee.dart';

/*
  cid  name     type           notnull  default  pk
  ---  -------  -------------  -------  -------  --
  0    Id       INT            0                 1
  1    Pattern  nvarchar(255)  1                 0
  2    Flags    INT            1                 0
  3    Payee    INT            1                 0
 */
class Alias extends MoneyObject {
  // 0
  // int MoneyEntity.Id

  // 1
  final String pattern;

  // 2
  final int flags;

  // 3
  final int payeeId;

  // Not persisted
  Payee? payeeInstance;
  RegExp? regex;

  Alias({
    required super.id,
    required this.pattern,
    required this.flags,
    required this.payeeId,
  });

  /// Constructor from a SQLite row
  factory Alias.fromSqlite(final Json row) {
    return Alias(
      // 0
      id: jsonGetInt(row, 'Id'),
      // 1
      pattern: jsonGetString(row, 'Pattern'),
      // 2
      flags: jsonGetInt(row, 'Flags'),
      // 3
      payeeId: jsonGetInt(row, 'Payee'),
    );
  }

  AliasType get type {
    return flags == 0 ? AliasType.none : AliasType.regex;
  }

  bool isMatch(final String text) {
    if (type == AliasType.regex) {
      // just in time creation of RegEx property
      regex ??= RegExp(pattern);
      final Match? matched = regex?.firstMatch(text);
      if (matched != null) {
        debugLog('First email found: ${matched.group(0)}');
        return true;
      }
    } else {
      if (stringCompareIgnoreCasing2(pattern, text) == 0) {
        return true;
      }
    }
    return false;
  }

  static FieldDefinition<Alias> getFieldForPayee() {
    return FieldDefinition<Alias>(
      type: FieldType.text,
      name: 'Payee',
      serializeName: 'payee',
      align: TextAlign.left,
      valueFromInstance: (final Alias item) {
        return Payee.getName(item.payeeInstance);
      },
      valueForSerialization: (final Alias item) {
        return item.payeeId;
      },
      sort: (final Alias a, final Alias b, final bool sortAscending) {
        return sortByString(
          Payee.getName(a.payeeInstance),
          Payee.getName(b.payeeInstance),
          sortAscending,
        );
      },
    );
  }

  static FieldDefinition<Alias> getFieldForType() {
    return FieldDefinition<Alias>(
      type: FieldType.text,
      name: 'Type',
      serializeName: 'Flags',
      align: TextAlign.left,
      valueFromInstance: (final Alias item) {
        return item.type.name;
      },
      valueForSerialization: (final Alias item) {
        return item.type.index;
      },
      sort: (final Alias a, final Alias b, final bool sortAscending) {
        return sortByString(a.type.name, b.type.name, sortAscending);
      },
    );
  }

  static FieldDefinition<Alias> getFieldForPattern() {
    return FieldDefinition<Alias>(
      type: FieldType.text,
      name: 'Pattern',
      serializeName: 'pattern',
      align: TextAlign.left,
      valueFromInstance: (final Alias item) {
        return item.pattern;
      },
      sort: (final Alias a, final Alias b, final bool sortAscending) {
        return sortByString(a.pattern, b.pattern, sortAscending);
      },
    );
  }

  static FieldDefinitions<Alias> getFieldDefinitions() {
    final FieldDefinitions<Alias> fields = FieldDefinitions<Alias>(definitions: <FieldDefinition<Alias>>[
      MoneyObject.getFieldId<Alias>(),
      FieldDefinition<Alias>(
        useAsColumn: false,
        name: 'PayeeId',
        serializeName: 'payeeId',
        valueFromInstance: (final Alias entity) => entity.payeeId,
      ),
      getFieldForPayee(),
      getFieldForPattern(),
      getFieldForType(),
    ]);
    return fields;
  }
}

enum AliasType {
  none, // 0
  regex, // 1
}
