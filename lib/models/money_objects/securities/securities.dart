import 'package:money/helpers/json_helper.dart';

import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/securities/security.dart';

// Exports
export 'package:money/models/money_objects/securities/security.dart';

class Securities extends MoneyObjects<Security> {
  @override
  loadFromJson(final List<Json> rows) {
    clear();
    for (final Json row in rows) {
      addEntry(Security.fromSqlite(row));
    }
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }
}
