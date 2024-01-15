import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/aliases/alias.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/payees/payee.dart';

class Aliases extends MoneyObjects<Alias> {
  Payee? findByMatch(final String text) {
    final Alias? aliasFound = getList().firstWhereOrNull((final Alias item) => item.isMatch(text));
    if (aliasFound == null) {
      return null;
    }
    return aliasFound.payeeInstance;
  }

  load(final List<Json> rows) async {
    clear();
    for (final Json row in rows) {
      addEntry(Alias.fromSqlite(row));
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
    for (final Alias item in getList()) {
      csv.writeln(Alias.getFieldDefinitions().getCsvRowValues(item));
    }

    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    return '\uFEFF$csv';
  }
}
