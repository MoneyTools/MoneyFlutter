import 'dart:math';

class Transaction {
  num id = -1;
  num accountId = -1;
  DateTime dateTime = DateTime(0);
  num payeeId = -1;
  double amount = 0.00;
  double balance = 0.00;

  Transaction(
      this.accountId, this.dateTime, this.payeeId, this.amount, this.balance);
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
      var amount = double.parse(row["Amount"].toString());

      list.add(Transaction(accountId, DateTime.parse(date), payee, amount,
          runningBalance += amount));
    }
    return list;
  }

  loadScale() {
    runningBalance = 0;
    list = List<Transaction>.generate(
        10000,
        (i) => Transaction(Random().nextInt(10), DateTime(2020, 02, i + 1),
            Random().nextInt(10), i * 1.0, (runningBalance += i).toDouble()));
  }
}
