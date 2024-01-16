import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/Currencies/Currency.dart';
import 'package:money/models/money_objects/money_objects.dart';

class Currencies extends MoneyObjects<Currency> {
  load(final List<Json> rows) async {
    clear();
    for (final Json row in rows) {
      addEntry(Currency.fromSqlite(row));
    }
  }

  loadDemoData() {
    clear();
  }

  static onAllDataLoaded() {}

  @override
  String toCSV() {
    return super.getCsvFromList(
      Currency.getFieldDefinitions(),
      getListSortedById(),
    );
  }
}
