import 'package:money/models/money_objects/investments/investment.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/storage/data/data.dart';

// Exports
export 'package:money/models/money_objects/investments/investment.dart';

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
      investment.transactionInstance = Data().transactions.get(investment.uniqueId);
    }
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }
}
