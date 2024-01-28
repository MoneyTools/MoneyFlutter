import 'dart:math';

import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
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

    int transactionId = 0;
    for (final Account account in Data().accounts.getList()) {
      for (int i = 0; i < getQuantityOfTransactionBasedOnAccountType(account.type.value); i++) {
        transactionForDemoData(transactionId, account);
        transactionId++;
      }
    }
  }

  int getQuantityOfTransactionBasedOnAccountType(final AccountType type) {
    switch (type) {
      case AccountType.savings:
        return 200;
      case AccountType.checking:
        return 900;
      case AccountType.moneyMarket:
        return 100;
      case AccountType.cash:
        return 12;
      case AccountType.credit:
        return 1000;
      case AccountType.investment:
        return 150;
      case AccountType.retirement:
        return 100;
      case AccountType.asset:
        return 10;
      case AccountType.categoryFund:
        return 10;
      case AccountType.loan:
        return 12 * 20;
      case AccountType.creditLine:
        return 50;
      default:
        return 500;
    }
  }

  void transactionForDemoData(final int transactionId, final Account account) {
    final double amount = getRandomAmount();
    runningBalance += amount;

    final Transaction t = Transaction()
      ..id.value = transactionId
      ..accountId.value = account.id.value
      ..dateTime.value = DateTime(2020, 02, transactionId + 1)
      ..payeeId.value = Random().nextInt(10)
      ..categoryId.value = Random().nextInt(10)
      ..amount.value = amount;

    getList().add(t);
  }

  double getRandomAmount() {
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
