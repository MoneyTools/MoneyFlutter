// ignore_for_file: unnecessary_this

// Imports
import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/data/models/money_objects/aliases/alias_types.dart';
import 'package:money/app/data/models/money_objects/payees/payee.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_item_card.dart';
import 'package:money/app/modules/home/sub_views/view_stocks/picker_security_type.dart';

// Export
export 'package:money/app/data/models/money_objects/aliases/alias_types.dart';

class Alias extends MoneyObject {
  Alias({
    required final int id,
    required final String pattern,
    required final int flags,
    required final int payeeId,
  }) {
    this.fieldId.value = id;
    this.fieldPattern.value = pattern;
    this.fieldFlags.value = flags;
    this.fieldPayeeId.value = payeeId;
  }

  /// Constructor from a SQLite row
  factory Alias.fromJson(final MyJson row) {
    return Alias(
      id: row.getInt('Id', -1),
      pattern: row.getString('Pattern'),
      flags: row.getInt('Flags'),
      payeeId: row.getInt('Payee', -1),
    );
  }

  /// 2    Flags    INT            1                 0
  FieldInt fieldFlags = FieldInt(
    type: FieldType.text,
    align: TextAlign.center,
    name: 'Flags',
    serializeName: 'Flags',
    defaultValue: 0,
    footer: FooterType.count,
    getValueForDisplay: (final MoneyObject instance) => getAliasTypeAsString((instance as Alias).type),
    getValueForSerialization: (final MoneyObject instance) => (instance as Alias).fieldFlags.value,
  );

  /// ID
  /// 0    Id       INT            0                 1
  FieldId fieldId = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as Alias).uniqueId,
  );

  /// Pattern
  /// 1    Pattern  nvarchar(255)  1                 0
  FieldString fieldPattern = FieldString(
    type: FieldType.text,
    name: 'Pattern',
    serializeName: 'Pattern',
    getValueForDisplay: (final MoneyObject instance) => (instance as Alias).fieldPattern.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Alias).fieldPattern.value,
  );

  /// Payee
  /// 3 Payee INT 1 0
  FieldInt fieldPayeeId = FieldInt(
    type: FieldType.text,
    footer: FooterType.count,
    name: 'Payee',
    serializeName: 'Payee',
    defaultValue: 0,
    getValueForDisplay: (final MoneyObject instance) => Payee.getName((instance as Alias).payeeInstance),
    getValueForSerialization: (final MoneyObject instance) => (instance as Alias).fieldPayeeId.value,
  );

  // Not persisted
  Payee? payeeInstance;

  RegExp? regex;

  @override
  Widget buildFieldsAsWidgetForSmallScreen() {
    return MyListItemAsCard(
      leftTopAsString: Payee.getName(payeeInstance),
      leftBottomAsString: fieldPattern.value,
      rightBottomAsString: '${getAliasTypeAsString(type)}\n',
    );
  }

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fieldsForColumnView.definitions;

  @override
  String getRepresentation() {
    return fieldPattern.value;
  }

  @override
  int get uniqueId => fieldId.value;

  @override
  set uniqueId(value) => fieldId.value = value;

  // static Fields<Alias> get fields {
  //   if (_fields.isEmpty) {
  //     final tmp = Alias.fromJson({});
  //     _fields.setDefinitions([
  //       tmp.fieldId,
  //       tmp.fieldPattern,
  //       tmp.fieldFlags,
  //       tmp.fieldPayeeId,
  //     ]);
  //   }
  //   return _fields;
  // }

  static final _fieldsForColumns = Fields<Alias>();

  static Fields<Alias> get fieldsForColumnView {
    if (_fieldsForColumns.isEmpty) {
      // used for the first time
      final tmp = Alias.fromJson({});
      _fieldsForColumns.setDefinitions([
        tmp.fieldPattern,
        tmp.fieldFlags,
        tmp.fieldPayeeId,
      ]);
    }

    // return the cached singleton
    return _fieldsForColumns;
  }

  bool isMatch(final String text) {
    if (type == AliasType.regex) {
      // just in time creation of RegEx property
      regex ??= RegExp(fieldPattern.value);
      final Match? matched = regex?.firstMatch(text);
      if (matched != null) {
        return true;
      }
    } else {
      if (stringCompareIgnoreCasing2(fieldPattern.value, text) == 0) {
        return true;
      }
    }
    return false;
  }

  AliasType get type {
    return fieldFlags.value == 0 ? AliasType.none : AliasType.regex;
  }
}
