import 'package:money/helpers/string_helper.dart';
import 'package:money/models/money_entity.dart';

class Transaction extends MoneyEntity {
  final int accountId;
  final DateTime dateTime;
  late final String dateTimeAsText;
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
  }) {
    dateTimeAsText = getDateAsText(dateTime);
  }

  @override
  String toString([final bool multiline = false]) {
    final String delimiter = multiline ? '\n' : ', ';
    return '${getDateAsText(dateTime)}$delimiter${getCurrencyText(amount)}$delimiter$memo';
  }
}

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
