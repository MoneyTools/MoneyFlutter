import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/investments/investment.dart';
import 'package:money/models/money_objects/money_objects.dart';

// Exports
export 'package:money/models/money_objects/investments/investment.dart';

class Investments extends MoneyObjects<Investment> {
  @override
  loadFromJson(final List<Json> rows) {
    clear();
    for (final Json row in rows) {
      addEntry(Investment.fromSqlite(row));
    }
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }
}
