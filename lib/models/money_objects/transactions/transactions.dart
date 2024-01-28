import 'dart:math';

import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

class Transactions extends MoneyObjects<Transaction> {
  double runningBalance = 0.00;

  void add(final Transaction transaction) {
    transaction.id.value = getList().length;
    getList().add(transaction);
  }

  @override
  List<Transaction> loadFromJson(final List<MyJson> rows) {
    clear();

    runningBalance = 0.00;

    for (final MyJson row in rows) {
      final Transaction t = Transaction.fromJSon(row, runningBalance);
      runningBalance += t.amount.value;
      getList().add(t);
    }
    return getList();
  }

  @override
  void loadDemoData() {
    clear();

    runningBalance = 0;

    for (int i = 0; i <= 9999; i++) {
      final double amount = getRandomAmount(i);
      runningBalance += amount;

      final Transaction t = Transaction()
        ..id.value = i
        ..accountId.value = Random().nextInt(5)
        ..dateTime.value = DateTime(2020, 02, i + 1)
        ..payeeId.value = Random().nextInt(10)
        ..categoryId.value = Random().nextInt(10)
        ..amount.value = amount;

      getList().add(t);
    }
  }

  double getRandomAmount(final int index) {
    final bool isExpense = (Random().nextInt(5) < 4); // Generate more expense transaction than income once
    final double amount = Random().nextDouble() * (isExpense ? -500 : 2500);
    return roundDouble(amount, 2);
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }
}
