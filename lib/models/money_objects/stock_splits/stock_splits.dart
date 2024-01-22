import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/stock_splits/stock_split.dart';
import 'package:money/models/money_objects/money_objects.dart';

// Exports
export 'package:money/models/money_objects/stock_splits/stock_split.dart';

class StockSplits extends MoneyObjects<StockSplit> {
  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      addEntry(StockSplit.fromSqlite(row));
    }
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }
}
