import 'package:money/app/data/models/money_objects/investments/investment.dart';
import 'package:money/app/data/models/money_objects/investments/stock_cumulative.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';

// Exports
export 'package:money/app/data/models/money_objects/investments/investment.dart';

class Investments extends MoneyObjects<Investment> {
  Investments() {
    collectionName = 'Investments';
  }

  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      appendMoneyObject(Investment.fromJson(row));
    }
  }

  @override
  void onAllDataLoaded() {
    for (final investment in iterableList()) {
      // hydrate the transaction instance associated to the investments
      final transactionFound = Data().transactions.get(investment.uniqueId);
      investment.transactionInstance = transactionFound ?? Transaction();
    }
  }

  static void calculateRunningBalance(List<Investment> investments) {
    // first sort by date, TradeType, Amount
    investments.sort((a, b) => Investment.sortByDateAndInvestmentType(a, b, true, true));

    double runningBalance = 0;
    for (final investment in investments) {
      runningBalance += investment.finalAmount.amount;
      investment.runningBalance.value.setAmount(runningBalance);
    }
  }

  static StockCumulative getProfitAndShares(List<Investment> investments) {
    // StockCumulative sort by date, TradeType, Amount
    investments.sort((a, b) => Investment.sortByDateAndInvestmentType(a, b, true, true));

    StockCumulative cumulative = StockCumulative();

    for (final investment in investments) {
      cumulative.quantity += investment.finalAmount.quantity;
      cumulative.amount += investment.finalAmount.amount;
    }
    return cumulative;
  }

  static getInvestmentsFromSecurity(final int securityId) {
    return Data().investments.iterableList().where((item) => item.security.value == securityId).toList();
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }
}
