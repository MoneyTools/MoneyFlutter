import 'package:money/core/helpers/string_helper.dart';
import 'package:money/data/models/money_objects/investments/investments.dart';
import 'package:money/data/models/money_objects/investments/stock_cumulative.dart';
import 'package:money/data/models/money_objects/securities/security.dart';
import 'package:money/data/storage/data/data.dart';

// Exports
export 'package:money/data/models/money_objects/securities/security.dart';

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
      security.fieldNumberOfTrades.value = list.length;

      final StockCumulative cumulative = Investments.getSharesAndProfit(list);
      security.fieldTransactionDateRange.value = cumulative.dateRange;
      security.fieldHoldingShares.value = cumulative.quantity;
      security.fieldActivityProfit.value.setAmount(cumulative.amount - cumulative.dividendsSum);
      security.fieldActivityDividend.value.setAmount(cumulative.dividendsSum);
      security.dividends = cumulative.dividends;
    }
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }

  Security? getBySymbol(final String symbolToFind) {
    return iterableList()
        .firstWhereOrNull((item) => stringCompareIgnoreCasing2(item.fieldSymbol.value, symbolToFind) == 0);
  }

  String getSymbolFromId(final int securityId) {
    final Security? security = get(securityId);
    if (security == null) {
      return '(?)';
    }
    return security.fieldSymbol.value;
  }
}
