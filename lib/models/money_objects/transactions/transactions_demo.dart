part of 'transactions.dart';

extension TransactionsDemoData on Transactions {
  void _loadDemoData() {
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

  void transactionForDemoData(final int transactionId, final Account account) {
    final double amount = getRandomAmount();

    final MyJson demoJson = <String, dynamic>{
      'Id': transactionId,
      'Account': account.id.value,
      'Date': DateTime(2020, 02, transactionId + 1),
      'Payee': Random().nextInt(10),
      'Category': Random().nextInt(10),
      'Amount': amount,
    };

    final Transaction t = Transaction.fromJSon(demoJson, runningBalance);
    runningBalance += amount;

    addEntry(t);
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

  double getRandomAmount() {
    final bool isExpense = (Random().nextInt(5) < 4); // Generate more expense transaction than income once
    final double amount = Random().nextDouble() * (isExpense ? -500 : 2500);
    return roundDouble(amount, 2);
  }
}
