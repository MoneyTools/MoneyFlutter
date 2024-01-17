import 'package:money/helpers/json_helper.dart';

import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/securities/security.dart';

// Exports
export 'package:money/models/money_objects/securities/security.dart';

class Securities extends MoneyObjects<Security> {
  load(final List<Json> rows) async {
    clear();
    for (final Json row in rows) {
      addEntry(Security.fromSqlite(row));
    }
  }

  loadDemoData() {
    clear();
  }

  static onAllDataLoaded() {}

  @override
  String toCSV() {
    return super.getCsvFromList(
      Security.getFieldDefinitions(),
      getListSortedById(),
    );
  }
}
