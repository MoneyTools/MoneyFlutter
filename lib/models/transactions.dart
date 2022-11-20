import 'dart:math';

import '../helpers.dart';

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
  double runningBalance = 0.00;

  static List<Transaction> list = [];

  load(rows) async {
    runningBalance = 0.00;

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

  loadDemoData() {
    runningBalance = 0;
    for(int i=0; i<=9999;i++){
      double amount = getRandomAmount(i);
      runningBalance += amount;
      list.add(Transaction(
          Random().nextInt(10), // Account Id
          DateTime(2020, 02, i + 1), // Date
          Random().nextInt(10), // Payee Id
          Random().nextInt(10), // Category Id
          amount, // Amount
          runningBalance // Balance
      ));
    }
  }

  getRandomAmount(index) {
    var isExpense = (Random().nextInt(5) < 4); // Generate more expense transaction than income once
    var amount = Random().nextDouble() * (isExpense ? -500 : 2500);
    return roundDouble(amount,2);
  }
}
