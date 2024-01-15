import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/loans/loan.dart';
import 'package:money/models/money_objects/money_objects.dart';

class Loans {
  MoneyObjects<Loan> moneyObjects = MoneyObjects<Loan>();

  Loan? get(final num id) {
    return moneyObjects.get(id);
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
      moneyObjects.addEntry(Loan.fromSqlite(row));
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
    for (final Loan item in moneyObjects.getAsList()) {
      csv.writeln(Loan.getFieldDefinitions().getCsvRowValues(item));
    }

    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    return '\uFEFF$csv';
  }
}
