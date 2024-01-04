import 'dart:math';

import 'package:money/models/money_entity.dart';

import 'package:money/helpers.dart';

enum TransactionStatus {
  none,
  electronic,
  cleared,
  reconciled,
  voided,
}

enum TransactionFlags {
  none, // 0
  unaccepted, // 1
  // 2
  budgeted,
  // 3
  filler3,
  // 4
  hasAttachment,
  // 5
  filler5,
  // 6
  filler6,
  // 7
  filler7,
  // 8
  notDuplicate,
  filler9,
  filler10,
  filler11,
  filler12,
  filler13,
  filler14,
  filler15,
  // 16
  hasStatement,
}

class Transaction extends MoneyEntity {
  final int accountId;
  final DateTime dateTime;
  final int payeeId;
  String originalPayee = ''; // before auto-aliasing, helps with future merging.
  final int categoryId;
  final double amount;
  double balance;

  double salesTax = 0;
  TransactionStatus status = TransactionStatus.none;

  String memo;
  String fitid;

  // String number; // requires value.Length < 10
  // // Investment investment;
  // Transfer transfer;
  // double runningUnits;
  // double runningBalance;
  // String routingPath;
  // TransactionFlags flags;
  // DateTime? reconciledDate;
  //
  // //Splits splits;
  // String pendingTransfer;
  // DateTime? budgetBalanceDate;
  //
  // //readonly Transaction related;
  // //readonly Split relatedSplit;
  // DateTime? mergeDate;
  //TransactionViewFlags viewState; // ui transient state only, not persisted.

  Transaction(
    super.id,
    super.name, {
    required this.dateTime,
    this.accountId = -1,
    this.payeeId = -1,
    this.categoryId = -1,
    this.amount = 0.00,
    this.balance = 0.00,
    this.memo = '',
    this.fitid = '',
  });
}

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
}
