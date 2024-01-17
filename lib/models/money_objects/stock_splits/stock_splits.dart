import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/stock_splits/stock_split.dart';
import 'package:money/models/money_objects/money_objects.dart';

// Exports
export 'package:money/models/money_objects/stock_splits/stock_split.dart';

class StockSplits extends MoneyObjects<StockSplit> {
  load(final List<Json> rows) async {
    clear();
    for (final Json row in rows) {
      addEntry(StockSplit.fromSqlite(row));
    }
  }

  loadDemoData() {
    clear();
  }

  onAllDataLoaded() {}

  @override
  String toCSV() {
    return super.getCsvFromList(
      StockSplit.getFieldDefinitions(),
      getListSortedById(),
    );
  }
}
