import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/database/database.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

part 'transactions_csv.dart';

part 'transactions_demo.dart';

part 'transactions_sql.dart';

class Transactions extends MoneyObjects<Transaction> {
  double runningBalance = 0.00;

  /// Remove/tag a Transaction instance from the list in memory
  bool deleteItem(final Transaction transaction) {
    transaction.change = ChangeType.deleted;
    Data().notifyTransactionChange(ChangeType.deleted, transaction);
    return false;
  }

  @override
  void loadDemoData() {
    _loadDemoData();
  }

  @override
  bool saveSql(final MyDatabase db) {
    return _saveSql(db);
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
    return getList();
  }

  int getNextTransactionId() {
    int maxIdFound = -1;
    for (final item in getList(true)) {
      maxIdFound = max(maxIdFound, item.id.value);
    }
    return maxIdFound + 1;
  }
}
