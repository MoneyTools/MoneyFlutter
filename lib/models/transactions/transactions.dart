import 'dart:math';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/transactions/transaction.dart';

class Transactions {
  double runningBalance = 0.00;

  static List<Transaction> list = <Transaction>[];

  static void add(final Transaction transaction) {
    transaction.id = list.length;
    list.add(transaction);
  }

  clear() {
    list.clear();
  }

  load(final List<Map<String, Object?>> rows) async {
    clear();

    runningBalance = 0.00;

    for (final Map<String, Object?> row in rows) {
      final Transaction t = Transaction(
        // id
        int.parse(row['Id'].toString()),
        '', // name
        // Account Id
        accountId: int.parse(row['Account'].toString()),
        // Date
        dateTime: DateTime.parse(row['Date'].toString()),
        // Payee Id
        payeeId: int.parse(row['Payee'].toString()),
        // Category Id
        categoryId: int.parse(row['Category'].toString()),
        // Amount
        amount: double.parse(row['Amount'].toString()),
        // Balance
        memo: row['Memo'].toString(),
      );

      runningBalance += t.amount;
      t.balance = runningBalance;

      list.add(t);
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
        '',
        // Account Id
        accountId: Random().nextInt(10),
        // Date
        dateTime: DateTime(2020, 02, i + 1),
        // Payee Id
        payeeId: Random().nextInt(10),
        // Category Id
        categoryId: Random().nextInt(10),
        // Amount
        amount: amount,
        // Balance
        balance: runningBalance,
      ));
    }
  }

  double getRandomAmount(final int index) {
    final bool isExpense = (Random().nextInt(5) < 4); // Generate more expense transaction than income once
    final double amount = Random().nextDouble() * (isExpense ? -500 : 2500);
    return roundDouble(amount, 2);
  }

  static String toCSV() {
    final StringBuffer csv = StringBuffer();

    // CSV Header
    csv.writeln(Transaction.getFieldDefinitions().getCsvHeader());

    // CSV Rows
    for (final Transaction item in Transactions.list) {
      csv.writeln(Transaction.getFieldDefinitions().getCsvRowValues(item));
    }
    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    return '\uFEFF$csv';
  }
}
