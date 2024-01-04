import 'dart:math';

import 'package:money/models/money_entity.dart';

import 'package:money/helpers.dart';

class Transaction extends MoneyEntity {
  num accountId = -1;
  DateTime dateTime = DateTime(0);
  int payeeId = -1;
  int categoryId = -1;
  double amount = 0.00;
  double balance = 0.00;

  Transaction(final int id, this.accountId, this.dateTime, this.payeeId, this.categoryId, this.amount, this.balance)
      : super(id, '');
}

class Transactions {
  double runningBalance = 0.00;

  static List<Transaction> list = <Transaction>[];

  clear() {
    list.clear();
  }

  load(final List<Map<String, Object?>> rows) async {
    clear();

    runningBalance = 0.00;

    for (final Map<String, Object?> row in rows) {
      final int id = int.parse(row['Id'].toString());
      final int accountId = int.parse(row['Account'].toString());
      final String date = row['Date'].toString();
      final int payee = int.parse(row['Payee'].toString());
      final int category = int.parse(row['Category'].toString());
      final double amount = double.parse(row['Amount'].toString());

      list.add(Transaction(
          id,
          accountId,
          // Account Id
          DateTime.parse(date),
          // Date
          payee,
          // Payee Id
          category,
          // Category Id
          amount,
          // Amount
          runningBalance += amount // Balance
          ));
    }
    return list;
  }

  loadDemoData() {
    clear();

    runningBalance = 0;

    for (int i = 0; i <= 9999; i++) {
      final double amount = getRandomAmount(i);
      runningBalance += amount;
      list.add(Transaction(
          i,
          Random().nextInt(10),
          // Account Id
          DateTime(2020, 02, i + 1),
          // Date
          Random().nextInt(10),
          // Payee Id
          Random().nextInt(10),
          // Category Id
          amount,
          // Amount
          runningBalance // Balance
          ));
    }
  }

  double getRandomAmount(final int index) {
    final bool isExpense = (Random().nextInt(5) < 4); // Generate more expense transaction than income once
    final double amount = Random().nextDouble() * (isExpense ? -500 : 2500);
    return roundDouble(amount, 2);
  }
}
