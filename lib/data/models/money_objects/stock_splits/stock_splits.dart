import 'package:money/core/helpers/date_helper.dart';
import 'package:money/core/helpers/json_helper.dart';
import 'package:money/data/models/money_objects/money_objects.dart';
import 'package:money/data/models/money_objects/securities/security.dart';
import 'package:money/data/models/money_objects/stock_splits/stock_split.dart';

// Exports
export 'package:money/data/models/money_objects/stock_splits/stock_split.dart';

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
    return MoneyObjects.getCsvFromList(getListSortedById());
  }

  void clearSplitForSecurity(final int securityId) {
    final Iterable<StockSplit> listOfSplitsFound = iterableList().where(
      (StockSplit split) => split.fieldSecurity.value == securityId,
    );
    for (final StockSplit ss in listOfSplitsFound) {
      deleteItem(ss);
    }
  }

  List<StockSplit> getStockSplitsForSecurity(final Security s) {
    final List<StockSplit> list = <StockSplit>[];
    for (StockSplit split in iterableList()) {
      if (!s.isDeleted && split.fieldSecurity.value == s.uniqueId) {
        list.add(split);
      }
    }
    list.sort((final StockSplit a, final StockSplit b) {
      return a.fieldDate.value!.compareTo(b.fieldDate.value!);
    });

    return list;
  }

  /// Only add, no removal of existing splits
  void setStockSplits(final int securityId, final List<StockSplit> values) {
    final List<StockSplit> listOfSplitsFound = iterableList()
        .where(
          (StockSplit split) => split.fieldSecurity.value == securityId,
        )
        .toList();
    for (final StockSplit ss in values) {
      final StockSplit? foundMatch = listOfSplitsFound.firstWhereOrNull(
        (StockSplit existingSplit) => isSameDateWithoutTime(
          existingSplit.fieldDate.value,
          ss.fieldDate.value,
        ),
      );
      if (foundMatch == null) {
        appendNewMoneyObject(ss, fireNotification: false);
      }
    }
  }
}
