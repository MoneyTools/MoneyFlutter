import 'dart:math';

import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

class Transactions extends MoneyObjects<Transaction> {
  double runningBalance = 0.00;

  void add(final Transaction transaction) {
    transaction.id = getList().length;
    getList().add(transaction);
  }

  load(final List<Json> rows) async {
    clear();

    runningBalance = 0.00;

    for (final Json row in rows) {
      final Transaction t = Transaction(
        // id
        id: int.parse(row['Id'].toString()),
        // Account Id
        accountId: int.parse(row['Account'].toString()),
        // Date
        dateTime: DateTime.parse(row['Date'].toString()),
        // Payee Id
        payeeId: int.parse(row['Payee'].toString()),
        // Category Id
        categoryId: int.parse(row['Category'].toString()),
        // Status
        status: TransactionStatus.values[int.parse(row['Status'].toString())],
        // Amount
        amount: double.parse(row['Amount'].toString()),
        // Balance
        memo: row['Memo'].toString(),
      );

      runningBalance += t.amount;
      t.balance = runningBalance;

      getList().add(t);
    }
    return getList();
  }

  loadDemoData() {
    clear();

    runningBalance = 0;

    for (int i = 0; i <= 9999; i++) {
      final double amount = getRandomAmount(i);
      runningBalance += amount;
      getList().add(Transaction(
        id: i,
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

  String toCSV() {
    final StringBuffer csv = StringBuffer();

    // CSV Header
    csv.writeln(Transaction.getFieldDefinitions().getCsvHeader());

    // CSV Rows
    for (final Transaction item in getList()) {
      csv.writeln(Transaction.getFieldDefinitions().getCsvRowValues(item));
    }
    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    return '\uFEFF$csv';
  }
}
