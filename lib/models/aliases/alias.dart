import 'dart:ui';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_entity.dart';
import 'package:money/models/payees/payee.dart';
import 'package:money/models/payees/payees.dart';

class Alias extends MoneyEntity {
  AliasType type = AliasType.none;
  int payeeId = -1;
  RegExp? regex;
  late final Payee payee;

  Alias(
    super.id,
    super.name, {
    this.type = AliasType.none,
    this.payeeId = -1,
  }) {
    payee = Payees.get(payeeId)!;
  }

  bool isMatch(final String text) {
    if (type == AliasType.regex) {
      // just in time creation of RegEx property
      regex ??= RegExp(name);
      final Match? matched = regex?.firstMatch(text);
      if (matched != null) {
        debugLog('First email found: ${matched.group(0)}');
        return true;
      }
    } else {
      if (stringCompareIgnoreCasing2(name, text) == 0) {
        return true;
      }
    }
    return false;
  }

  static FieldDefinition<Alias> getFieldForPayee() {
    return FieldDefinition<Alias>(
      name: 'Payee',
      type: FieldType.text,
      align: TextAlign.left,
      valueFromInstance: (final Alias item) {
        return Payees.getNameFromId(item.payeeId);
      },
      sort: (final Alias a, final Alias b, final bool sortAscending) {
        return sortByString(Payees.getNameFromId(a.payeeId), Payees.getNameFromId(b.payeeId), sortAscending);
      },
    );
  }

  static FieldDefinition<Alias> getFieldForType() {
    return FieldDefinition<Alias>(
      name: 'Type',
      type: FieldType.text,
      align: TextAlign.left,
      valueFromInstance: (final Alias item) {
        return item.type.toString();
      },
      sort: (final Alias a, final Alias b, final bool sortAscending) {
        return sortByString(a.type.toString(), b.type.toString(), sortAscending);
      },
    );
  }

  static FieldDefinition<Alias> getFieldForPattern() {
    return FieldDefinition<Alias>(
      name: 'Pattern',
      type: FieldType.text,
      align: TextAlign.left,
      valueFromInstance: (final Alias item) {
        return item.name;
      },
      sort: (final Alias a, final Alias b, final bool sortAscending) {
        return sortByString(a.name, b.name, sortAscending);
      },
    );
  }

  static FieldDefinitions<Alias> getFieldDefinitions() {
    final FieldDefinitions<Alias> fields = FieldDefinitions<Alias>(definitions: <FieldDefinition<Alias>>[
      FieldDefinition<Alias>(
        name: 'Id',
        serializeName: 'id',
        type: FieldType.text,
        align: TextAlign.left,
        valueFromList: (final int index) => '',
        valueFromInstance: (final Alias entity) => entity.id,
        sort: (final Alias a, final Alias b, final bool sortAscending) {
          return sortByValue(a.id, b.id, sortAscending);
        },
      ),
      FieldDefinition<Alias>(
        name: 'Name',
        serializeName: 'name',
        type: FieldType.text,
        align: TextAlign.left,
        valueFromInstance: (final Alias entity) => entity.name,
        sort: (final Alias a, final Alias b, final bool sortAscending) {
          return sortByString(a.name, b.name, sortAscending);
        },
      ),
      FieldDefinition<Alias>(
        serializeName: 'payeeId',
        valueFromInstance: (final Alias entity) => entity.payeeId,
      ),
      getFieldForPayee(),
      getFieldForType(),
      getFieldForPattern(),
    ]);
    return fields;
  }

  static getCsvHeader() {
    final List<String> headerList = <String>[];
    getFieldDefinitions().definitions.forEach((final FieldDefinition<Alias> field) {
      if (field.serializeName != null) {
        headerList.add(field.serializeName!);
      }
    });
    return headerList.join(',');
  }
}

enum AliasType {
  none,
  regex,
}
