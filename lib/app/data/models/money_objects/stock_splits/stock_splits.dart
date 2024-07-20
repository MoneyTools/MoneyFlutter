import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';
import 'package:money/app/data/models/money_objects/stock_splits/stock_split.dart';

// Exports
export 'package:money/app/data/models/money_objects/stock_splits/stock_split.dart';

class StockSplits extends MoneyObjects<StockSplit> {
  StockSplits() {
    collectionName = 'Stock Splits';
  }

  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      appendMoneyObject(StockSplit.fromJson(row));
    }
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }

  List<StockSplit> getStockSplitsForSecurity(final Security s) {
    List<StockSplit> list = [];
    for (StockSplit split in iterableList()) {
      if (!s.isDeleted && split.security.value == s.uniqueId) {
        list.add(split);
      }
    }
    list.sort((final StockSplit a, final StockSplit b) {
      return a.date.value!.compareTo(b.date.value!);
    });

    return list;
  }

  bool isSplitFound(final int securityId, final int year, final int month, final int day) {
    for (StockSplit split in iterableList()) {
      if (split.security.value == securityId) {
        if (split.date.value!.year == year && split.date.value!.month == month && split.date.value!.day == day) {
          return true;
        }
      }
    }
    return false;
  }
}
