part of 'transactions.dart';

extension TransactionsDemoData on Transactions {
  void _loadDemoData() {
    clear();

    runningBalance = 0;

    for (final Account account in Data().accounts.iterableList()) {
      final numberOfDatesNeeded = getQuantityOfTransactionBasedOnAccountType(account.type.value);
      final dates = generateRandomDates(numberOfDatesNeeded);
      for (final date in dates) {
        transactionForDemoData(date, account);
      }
    }
  }

  List<DateTime> generateRandomDates(int count) {
    final now = DateTime.now();
    final tenYearsAgo = now.subtract(const Duration(days: 365 * 10)); // Adjust for leap years if needed

    final random = Random();
    final dates = List<DateTime>.generate(count, (index) {
      final randomDaysSinceTenYearsAgo = random.nextInt(365 * 10); // Random days within 10 years
      return tenYearsAgo.add(Duration(days: randomDaysSinceTenYearsAgo));
    });
    return dates;
  }

  void transactionForDemoData(final DateTime date, final Account account) {
    int categoryId = Random().nextInt(10);

    int payeeId = Random().nextInt(10);
    
    if (payeeId == 0 || payeeId == 1) {
      // The first tow payees are "Food related" so assign the "Food" category
      categoryId = Data().categories.getByName('Food')!.uniqueId;
    }

    // generate an amount
    // Expenses should be a negative value;
    final double amount = getRandomAmount() * (Data().categories.isCategoryAnExpense(categoryId) ? -1 : 1);

    final MyJson demoJson = <String, dynamic>{
      'Id': -1,
      'Account': account.id.value,
      'Date': date,
      'Payee': payeeId,
      'Category': categoryId,
      'Amount': amount,
    };

    final Transaction t = Transaction.fromJSon(demoJson, runningBalance);
    runningBalance += amount;

    appendNewMoneyObject(t, fireNotification: false);
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
