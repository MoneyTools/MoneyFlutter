import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

class Payees {
  MoneyObjects<Payee> moneyObjects = MoneyObjects<Payee>();

  Payee? get(final int id) {
    return moneyObjects.get(id);
  }

  String getNameFromId(final int id) {
    final Payee? payee = moneyObjects.get(id);
    if (payee == null) {
      return '';
    }
    return payee.name;
  }

  Payee? getByName(final String name) {
    return moneyObjects.getAsList().firstWhereOrNull((final Payee payee) => payee.name == name);
  }

  /// Attempts to find payee wih the given name
  /// if not found create a new payee and return that instance
  Payee findOrAddPayee(final String name) {
    // find or add account of given name
    Payee? payee = getByName(name);

    // if not found add new payee
    payee ??= Payee(
      id: moneyObjects.length,
      name: name,
    );
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
      moneyObjects.addEntry(Payee(id: id, name: name));
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
      moneyObjects.addEntry(Payee(id: i, name: names[i]));
    }
  }

  onAllDataLoaded() {
    for (final Payee payee in moneyObjects.getAsList()) {
      payee.count = 0;
      payee.balance = 0;
    }

    for (Transaction t in Data().transactions.list) {
      final Payee? item = get(t.payeeId);
      if (item != null) {
        item.count++;
        item.balance += t.amount;
      }
    }
  }

  String toCSV() {
    final StringBuffer csv = StringBuffer();

    // CSV Header
    csv.writeln(Payee.getFieldDefinitions().getCsvHeader());

    // CSV Rows
    for (final Payee item in moneyObjects.getAsList()) {
      csv.writeln(Payee.getFieldDefinitions().getCsvRowValues(item));
    }
    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    return '\uFEFF$csv';
  }
}
