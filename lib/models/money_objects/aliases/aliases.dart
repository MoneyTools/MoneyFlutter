import 'package:collection/collection.dart';
import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/aliases/alias.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/payees/payee.dart';

class Aliases {
  MoneyObjects<Alias> moneyObjects = MoneyObjects<Alias>();

  Alias? get(final num id) {
    return moneyObjects.get(id);
  }

  Payee? findByMatch(final String text) {
    final Alias? aliasFound = moneyObjects.getAsList().firstWhereOrNull((final Alias item) => item.isMatch(text));
    if (aliasFound == null) {
      return null;
    }
    return aliasFound.payeeInstance;
  }

  clear() {
    moneyObjects.clear();
  }

  int length() {
    return moneyObjects.getAsList().length;
  }

  load(final List<Json> rows) async {
    clear();
    for (final Json row in rows) {
      moneyObjects.addEntry(Alias.fromSqlite(row));
    }
  }

  loadDemoData() {
    clear();
  }

  static onAllDataLoaded() {}

  String toCSV() {
    final StringBuffer csv = StringBuffer();

    // CSV Header
    csv.writeln(Alias.getFieldDefinitions().getCsvHeader());

    // CSV Rows
    for (final Alias item in moneyObjects.getAsList()) {
      csv.writeln(Alias.getFieldDefinitions().getCsvRowValues(item));
    }

    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    return '\uFEFF$csv';
  }
}
