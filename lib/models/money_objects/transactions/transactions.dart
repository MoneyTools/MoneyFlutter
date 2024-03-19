import 'dart:math';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

export 'package:money/models/money_objects/transactions/transaction.dart';

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
      runningBalance += t.balance.value;
      addEntry(moneyObject: t);
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

  Transaction? findExistingTransaction({
    required final DateTime dateTime,
    required final String payeeAsText,
    required final String memo,
    required final double amount,
  }) {
    // TODO make this more precises, at the moment we only match amount and date YYYY,MM,DD
    return iterableList(true).firstWhereOrNull((transaction) {
      if (transaction.amount.value == amount) {
        if (transaction.dateTime.value?.year == dateTime.year &&
            transaction.dateTime.value?.month == dateTime.month &&
            transaction.dateTime.value?.day == dateTime.day) {
          return true;
        }
      }
      return false;
    });
  }
}
