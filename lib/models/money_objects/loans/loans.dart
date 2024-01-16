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

  @override
  String toCSV() {
    return super.getCsvFromList(
      Loan.getFieldDefinitions(),
      getListSortedById(),
    );
  }
}
