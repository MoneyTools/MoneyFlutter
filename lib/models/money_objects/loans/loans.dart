import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/loans/loan.dart';
import 'package:money/models/money_objects/money_objects.dart';

class Loans extends MoneyObjects<Loan> {
  load(final List<Json> rows) async {
    clear();
    for (final Json row in rows) {
      addEntry(Loan.fromSqlite(row));
    }
  }

  loadDemoData() {
    clear();
  }

  static onAllDataLoaded() {}

  String toCSV() {
    final StringBuffer csv = StringBuffer();

    // CSV Header
    csv.writeln(Loan.getFieldDefinitions().getCsvHeader());

    // CSV Rows
    for (final Loan item in getList()) {
      csv.writeln(Loan.getFieldDefinitions().getCsvRowValues(item));
    }

    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    return '\uFEFF$csv';
  }
}
