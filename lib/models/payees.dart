import 'dart:ui';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_entity.dart';
import 'package:money/models/transactions.dart';

class Payee extends MoneyEntity {
  num count = 0;
  double balance = 0.00;

  Payee(super.id, super.name);

  static FieldDefinitions<Payee> getFieldDefinitions() {
    final FieldDefinitions<Payee> fields = FieldDefinitions<Payee>(list: <FieldDefinition<Payee>>[
      FieldDefinition<Payee>(
        name: 'Id',
        serializeName: 'id',
        type: FieldType.text,
        align: TextAlign.left,
        valueFromList: (final int index) => '',
        valueFromInstance: (final Payee entity) => entity.id,
        sort: (final Payee a, final Payee b, final bool sortAscending) {
          return sortByValue(a.id, b.id, sortAscending);
        },
      ),
      FieldDefinition<Payee>(
        name: 'Name',
        serializeName: 'name',
        type: FieldType.text,
        align: TextAlign.left,
        valueFromInstance: (final Payee entity) => entity.name,
        sort: (final Payee a, final Payee b, final bool sortAscending) {
          return sortByString(a.name, b.name, sortAscending);
        },
      ),
      FieldDefinition<Payee>(
        name: 'Count',
        type: FieldType.numeric,
        align: TextAlign.right,
        valueFromInstance: (final Payee entity) => entity.count,
        sort: (final Payee a, final Payee b, final bool sortAscending) {
          return sortByValue(
            a.count,
            b.count,
            sortAscending,
          );
        },
      ),
      FieldDefinition<Payee>(
        name: 'Balance',
        type: FieldType.amount,
        align: TextAlign.right,
        valueFromInstance: (final Payee entity) => entity.balance,
        sort: (final Payee a, final Payee b, final bool sortAscending) {
          return sortByValue(
            a.balance,
            b.balance,
            sortAscending,
          );
        },
      ),
    ]);
    return fields;
  }

  static getCsvHeader() {
    final List<String> headerList = <String>[];
    getFieldDefinitions().list.forEach((final FieldDefinition<Payee> field) {
      if (field.serializeName != null) {
        headerList.add(field.serializeName!);
      }
    });
    return headerList.join(',');
  }
}

class Payees {
  static MoneyObjects<Payee> moneyObjects = MoneyObjects<Payee>();

  static Payee? get(final int id) {
    return moneyObjects.get(id);
  }

  static String getNameFromId(final int id) {
    return moneyObjects.getNameFromId(id);
  }

  /// Attempts to find payee wih the given name
  /// if not found create a new payee and return that instance
  static Payee findOrAddPayee(final String name) {
    // find or add account of given name
    Payee? payee = moneyObjects.getByName(name);

    // if not found add new payee
    payee ??= Payee(moneyObjects.length, name);
    return payee;
  }

  clear() {
    moneyObjects.clear();
  }

  int length() {
    return moneyObjects.getAsList().length;
  }

  load(final List<Map<String, Object?>> rows) async {
    clear();
    /*
     */
    for (final Map<String, Object?> row in rows) {
      final int id = int.parse(row['Id'].toString());
      final String name = row['Name'].toString();
      moneyObjects.addEntry(Payee(id, name));
    }
  }

  loadDemoData() {
    clear();

    final List<String> names = <String>[
      'John',
      'Paul',
      'George',
      'Ringo',
      'Jean-Pierre',
      'Chris',
      'Bill',
      'Steve',
      'Sue',
      'Barbara'
    ];
    for (int i = 0; i < names.length; i++) {
      moneyObjects.addEntry(Payee(i, names[i]));
    }
  }

  static onAllDataLoaded() {
    for (final Payee payee in moneyObjects.getAsList()) {
      payee.count = 0;
      payee.balance = 0;
    }

    for (Transaction t in Transactions.list) {
      final Payee? item = get(t.payeeId);
      if (item != null) {
        item.count++;
        item.balance += t.amount;
      }
    }
  }

  static String toCSV() {
    final StringBuffer csv = StringBuffer();

    // CSV Header
    csv.writeln(Payee.getFieldDefinitions().getCsvHeader());

    // CSV Rows
    for (final Payee item in Payees.moneyObjects.getAsList()) {
      csv.writeln(Payee.getFieldDefinitions().getCsvRowValues(item));
    }
    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    return '\uFEFF$csv';
  }
}
