import 'dart:math';

class Transaction {
  num id = -1;
  num accountId = -1;
  DateTime dateTime = DateTime(0);
  num payeeId = -1;
  num categoryId = -1;
  double amount = 0.00;
  double balance = 0.00;

  Transaction(this.accountId, this.dateTime, this.payeeId, this.categoryId,
      this.amount, this.balance);
}

class Transactions {
  num runningBalance = 0;

  static List<Transaction> list = [];

  load(rows) async {
    runningBalance = 0;

    for (var row in rows) {
      var accountId = num.parse(row["Account"].toString());
      var date = row["Date"].toString();
      var payee = num.parse(row["Payee"].toString());
      var category = num.parse(row["Category"].toString());
      var amount = double.parse(row["Amount"].toString());

      list.add(Transaction(
          accountId, // Account Id
          DateTime.parse(date), // Date
          payee, // Payee Id
          category, // Category Id
          amount, // Amount
          runningBalance += amount // Balance
          ));
    }
    return list;
  }

  loadScale() {
    runningBalance = 0;
    list = List<Transaction>.generate(
        10000,
        (i) => Transaction(
            Random().nextInt(10), // Account Id
            DateTime(2020, 02, i + 1), // Date
            Random().nextInt(10), // Payee Id
            Random().nextInt(10), // Category Id
            i * 1.0, // Amount
            (runningBalance += i).toDouble() // Balance
            ));
  }
}
