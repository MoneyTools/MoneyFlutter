import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/data/models/money_objects/investments/investments.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';
import 'package:money/app/data/storage/data/data.dart';

// Exports
export 'package:money/app/data/models/money_objects/securities/security.dart';

class Securities extends MoneyObjects<Security> {
  Securities() {
    collectionName = 'Securities';
  }

  String getSymbolFromId(final int securityId) {
    final Security? security = get(securityId);
    if (security == null) {
      return '?$security?';
    }
    return security.symbol.value;
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
      final List<Investment> list = Investments.getInvestmentsFromSecurity(security.uniqueId);
      security.numberOfTrades.value = list.length;
      final cumulative = Investments.getProfitAndShares(list);
      security.outstandingShares.value = cumulative.quantity;
      security.balance.value.setAmount(cumulative.amount);
    }
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }
}
