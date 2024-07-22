import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/data/models/money_objects/investments/investments.dart';
import 'package:money/app/data/models/money_objects/investments/stock_cumulative.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';
import 'package:money/app/data/storage/data/data.dart';

// Exports
export 'package:money/app/data/models/money_objects/securities/security.dart';

class Securities extends MoneyObjects<Security> {
  Securities() {
    collectionName = 'Securities';
  }

  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      appendMoneyObject(Security.fromJson(row));
    }
  }

  @override
  void onAllDataLoaded() {
    for (final Security security in iterableList()) {
      security.splitsHistory = Data().stockSplits.getStockSplitsForSecurity(security);

      final List<Investment> list = security.getAssociatedInvestments();
      security.numberOfTrades.value = list.length;

      final StockCumulative cumulative = Investments.getSharesAndProfit(list);
      security.transactionDateRange.value = cumulative.dateRange;
      security.holdingShares.value = cumulative.quantity;
      security.activityProfit.value.setAmount(cumulative.amount - cumulative.dividend);
      security.activityDividend.value.setAmount(cumulative.dividend);
    }
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }

  Security? getBySymbol(final String symbolToFind) {
    return iterableList().firstWhereOrNull((item) => stringCompareIgnoreCasing2(item.symbol.value, symbolToFind) == 0);
  }

  String getSymbolFromId(final int securityId) {
    final Security? security = get(securityId);
    if (security == null) {
      return '?$security?';
    }
    return security.symbol.value;
  }
}
