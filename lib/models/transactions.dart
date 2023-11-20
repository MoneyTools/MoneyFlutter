import 'dart:math';

import 'package:money/models/money_entity.dart';

import '../helpers.dart';

class Transaction extends MoneyEntity {
  num accountId = -1;
  DateTime dateTime = DateTime(0);
  num payeeId = -1;
  num categoryId = -1;
  double amount = 0.00;
  double balance = 0.00;

  Transaction(id, this.accountId, this.dateTime, this.payeeId, this.categoryId, this.amount, this.balance) : super(id, '');
}

class Transactions {
  double runningBalance = 0.00;

  static List<Transaction> list = [];

  clear() {
    list.clear();
  }

  load(rows) async {
    clear();

    runningBalance = 0.00;

    for (var row in rows) {
      var id = num.parse(row['Id'].toString());
      var accountId = num.parse(row['Account'].toString());
      var date = row['Date'].toString();
      var payee = num.parse(row['Payee'].toString());
      var category = num.parse(row['Category'].toString());
      var amount = double.parse(row['Amount'].toString());

      list.add(Transaction(
          id,
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
    clear();

    runningBalance = 0;

    for (int i = 0; i <= 9999; i++) {
      double amount = getRandomAmount(i);
      runningBalance += amount;
      list.add(Transaction(
          i,
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
    return roundDouble(amount, 2);
  }
}
