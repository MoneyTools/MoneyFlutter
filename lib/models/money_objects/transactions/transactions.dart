import 'dart:math';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

part 'transactions_csv.dart';

part 'transactions_demo.dart';

class Transactions extends MoneyObjects<Transaction> {
  double runningBalance = 0.00;

  @override
  void loadDemoData() {
    _loadDemoData();
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }

  @override
  List<Transaction> loadFromJson(final List<MyJson> rows) {
    clear();

    runningBalance = 0.00;

    for (final MyJson row in rows) {
      final Transaction t = Transaction.fromJSon(row, runningBalance);
      runningBalance += t.getNormalizedAmount();
      addEntry(t);
    }
    return iterableList().toList();
  }

  int getNextTransactionId() {
    int maxIdFound = -1;
    for (final item in iterableList(true)) {
      maxIdFound = max(maxIdFound, item.id.value);
    }
    return maxIdFound + 1;
  }
}
