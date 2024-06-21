// Imports
import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/data/models/fields/fields.dart';
import 'package:money/app/data/models/money_objects/aliases/alias_types.dart';
import 'package:money/app/data/models/money_objects/payees/payee.dart';
import 'package:money/views/adaptive_view/adaptive_list/list_item_card.dart';

// Export
export 'package:money/app/data/models/money_objects/aliases/alias_types.dart';

class Alias extends MoneyObject {
  static final _fields = Fields<Alias>();

  static get fields {
    if (_fields.isEmpty) {
      final tmp = Alias.fromJson({});
      _fields.setDefinitions([
        tmp.id,
        tmp.pattern,
        tmp.flags,
        tmp.payeeId,
      ]);
    }
    return _fields;
  }

  static getFields() {
    if (fields == null) {
      Alias.fromJson({});
    }
    return fields;
  }

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  @override
  String getRepresentation() {
    return pattern.value;
  }

  /// ID
  /// 0    Id       INT            0                 1
  FieldId id = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as Alias).uniqueId,
  );

  /// Pattern
  /// 1    Pattern  nvarchar(255)  1                 0
  Field<String> pattern = Field<String>(
    type: FieldType.text,
    importance: 2,
    name: 'Pattern',
    serializeName: 'Pattern',
    defaultValue: '',
    getValueForDisplay: (final MoneyObject instance) => (instance as Alias).pattern.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Alias).pattern.value,
  );

  /// 2    Flags    INT            1                 0
  Field<int> flags = Field<int>(
    type: FieldType.text,
    align: TextAlign.center,
    importance: 3,
    name: 'Flags',
    serializeName: 'Flags',
    defaultValue: 0,
    getValueForDisplay: (final MoneyObject instance) => getAliasTypeAsString((instance as Alias).type),
    getValueForSerialization: (final MoneyObject instance) => (instance as Alias).flags.value,
  );

  /// Payee
  /// 3 Payee INT 1 0
  Field<int> payeeId = Field<int>(
    type: FieldType.text,
    importance: 1,
    name: 'Payee',
    serializeName: 'Payee',
    defaultValue: 0,
    getValueForDisplay: (final MoneyObject instance) => Payee.getName((instance as Alias).payeeInstance),
    getValueForSerialization: (final MoneyObject instance) => (instance as Alias).payeeId.value,
  );

  // Not persisted
  Payee? payeeInstance;
  RegExp? regex;

  Alias({
    required final int id,
    required final String pattern,
    required final int flags,
    required final int payeeId,
  }) {
    this.id.value = id;
    this.pattern.value = pattern;
    this.flags.value = flags;
    this.payeeId.value = payeeId;
    buildFieldsAsWidgetForSmallScreen = () => MyListItemAsCard(
          leftTopAsString: Payee.getName(payeeInstance),
          leftBottomAsString: this.pattern.value,
          rightBottomAsString: '${getAliasTypeAsString(type)}\n',
        );
  }

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  /// Constructor from a SQLite row
  factory Alias.fromJson(final MyJson row) {
    return Alias(
      id: row.getInt('Id', -1),
      pattern: row.getString('Pattern'),
      flags: row.getInt('Flags'),
      payeeId: row.getInt('Payee', -1),
    );
  }

  AliasType get type {
    return flags.value == 0 ? AliasType.none : AliasType.regex;
  }

  bool isMatch(final String text) {
    if (type == AliasType.regex) {
      // just in time creation of RegEx property
      regex ??= RegExp(pattern.value);
      final Match? matched = regex?.firstMatch(text);
      if (matched != null) {
        //debugLog('First email found: ${matched.group(0)}');
        return true;
      }
    } else {
      if (stringCompareIgnoreCasing2(pattern.value, text) == 0) {
        return true;
      }
    }
    return false;
  }
}
