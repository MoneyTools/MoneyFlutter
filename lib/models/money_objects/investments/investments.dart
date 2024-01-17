import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/investments/investment.dart';
import 'package:money/models/money_objects/money_objects.dart';

// Exports
export 'package:money/models/money_objects/investments/investment.dart';

class Investments extends MoneyObjects<Investment> {
  load(final List<Json> rows) async {
    clear();
    for (final Json row in rows) {
      addEntry(Investment.fromSqlite(row));
    }
  }

  loadDemoData() {
    clear();
  }

  static onAllDataLoaded() {}

  @override
  String toCSV() {
    return super.getCsvFromList(
      Investment.getFieldDefinitions(),
      getListSortedById(),
    );
  }
}
