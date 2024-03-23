part of 'transactions.dart';

extension TransactionsDemoData on Transactions {
  void _loadDemoData() {
    clear();

    runningBalance = 0;

    int day = 0;
    for (final Account account in Data().accounts.iterableList()) {
      for (int i = 0; i < getQuantityOfTransactionBasedOnAccountType(account.type.value); i++) {
        transactionForDemoData(day, account);
        day++;
      }
    }
  }

  void transactionForDemoData(final int day, final Account account) {
    final categoryId = Random().nextInt(10);

    // generate an amount
    // Expenses should be a negative value;
    final double amount = getRandomAmount() * (Data().categories.isCategoryAnExpense(categoryId) ? -1 : 1);

    final MyJson demoJson = <String, dynamic>{
      'Id': -1,
      'Account': account.id.value,
      'Date': DateTime(2020, 02, day + 1),
      'Payee': Random().nextInt(10),
      'Category': categoryId,
      'Amount': amount,
    };

    final Transaction t = Transaction.fromJSon(demoJson, runningBalance);
    runningBalance += amount;

    appendNewMoneyObject(t);
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
