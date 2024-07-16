import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/data/models/fields/fields.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/money_object.dart';
import 'package:money/app/data/models/money_objects/splits/splits.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';

class Transfer extends MoneyObject {
  Transfer({
    required this.id,
    required this.source,
    required this.isOrphan,
    this.related,
    this.sourceSplit,
    this.relatedSplit,
  }) {
    // body of constructor
  }

  factory Transfer.fromJson(final MyJson row) {
    return Transfer(id: -1, source: null, isOrphan: true);
  }

  final num id; // used when the transfer is part of a split
  final bool isOrphan;
  final Transaction? related; // the related transaction
  final MoneySplit? relatedSplit; // the related split, if it is a transfer in a split.
  final Transaction? source; // the source of the transfer.
  final MoneySplit? sourceSplit; // the source split, if it is a transfer in a split.

  /// Status
  FieldString accountStatusDestination = FieldString(
    importance: 12,
    name: 'RS',
    align: TextAlign.center,
    columnWidth: ColumnWidth.nano,
    getValueForDisplay: (final MoneyObject instance) =>
        transactionStatusToLetter((instance as Transfer).related!.status.value),
  );

  /// memo
  FieldString memoDestination = FieldString(
    importance: 97,
    name: 'Recipient memo',
    columnWidth: ColumnWidth.largest,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).getMemoDestination(),
  );

  /// Account
  Field<int> receiverAccountId = Field<int>(
    importance: 11,
    type: FieldType.text,
    name: 'Recipient account',
    defaultValue: -1,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).getReceiverAccountName(),
  );

  //
  // RECEIVED
  //

  /// Date received
  FieldDate receiverTransactionDate = FieldDate(
    importance: 10,
    name: 'Date Received',
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).getReceiverTransactionDate(),
  );

  /// Account
  Field<int> senderAccountId = Field<int>(
    importance: 2,
    type: FieldType.text,
    name: 'Sender',
    defaultValue: -1,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).getSenderAccountName(),
  );

  //
  // SENDER
  //
  FieldDate senderTransactionDate = FieldDate(
    importance: 1,
    name: 'Sent on',
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).geSenderTransactionDate(),
  );

  /// memo
  FieldString senderTransactionMemo = FieldString(
    importance: 4,
    name: 'Sender memo',
    columnWidth: ColumnWidth.largest,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).getMemoSource(),
  );

  /// Status
  FieldString senderTransactionStatus = FieldString(
    importance: 3,
    name: 'SS',
    align: TextAlign.center,
    columnWidth: ColumnWidth.nano,
    getValueForDisplay: (final MoneyObject instance) =>
        transactionStatusToLetter((instance as Transfer).source!.status.value),
  );

  /// Transfer amount
  FieldMoney transactionAmount = FieldMoney(
    importance: 99,
    name: 'Amount',
    columnWidth: ColumnWidth.small,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).source!.amount.value,
  );

  ///
  /// Common
  ///

  /// Troubleshoot
  FieldString troubleshoot = FieldString(
    importance: 98,
    name: 'Troubleshoot',
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).getTroubleshoot(),
  );

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  @override
  int get uniqueId => source!.uniqueId;

  static final _fields = Fields<Transfer>();

  int dateSpreadBetweenSendingAndReceiving() {
    DateTime dateSent = geSenderTransactionDate() ?? DateTime.now();
    DateTime dateReceived = getReceivedDateOrToday();
    return dateReceived.difference(dateSent).inDays;
  }

  //---------------------------------------------

  String evaluatedReceivedDate() {
    return dateToString(getReceivedDateOrToday());
  }

  static Fields<Transfer> get fields {
    if (_fields.isEmpty) {
      final tmp = Transfer.fromJson({});

      _fields.setDefinitions([
        tmp.senderTransactionDate,
        tmp.senderAccountId,
        tmp.senderTransactionStatus,
        tmp.senderTransactionMemo,
        tmp.receiverTransactionDate,
        tmp.receiverAccountId,
        tmp.accountStatusDestination,
        tmp.memoDestination,
        tmp.troubleshoot,
        tmp.transactionAmount,
      ]);
    }
    return _fields;
  }

  double geReceiverTransactionAmount() {
    if (related != null) {
      return related!.amount.value.toDouble();
    }
    return 0.00;
  }

  //---------------------------------------------

  //---------------------------------------------
  // Amounts
  double geSenderTransactionAmount() {
    return source!.amount.value.toDouble();
  }

  //---------------------------------------------

  //---------------------------------------------
  /// Dates
  DateTime? geSenderTransactionDate() {
    return source!.dateTime.value;
  }

  String getMemoDestination() {
    String memos = source!.transferSplit.value == -1 ? '' : '[Split:${source!.transferSplit.value}] ';
    if (related != null) {
      memos += related!.memo.value;
    }
    return memos;
  }

  String getMemoSource() {
    return source!.memo.value;
  }

  DateTime getReceivedDateOrToday() {
    return getReceiverTransactionDate() ?? DateTime.now();
  }

  Account? getReceiverAccount() {
    if (related != null) {
      return related!.getAccount();
    }
    return null;
  }

  String getReceiverAccountName() {
    return (getReceiverAccount()?.name.value) ?? '<account not found>';
  }

  Transaction? getReceiverTransaction() {
    if (related != null) {
      return related!;
    }

    return null;
  }

  DateTime? getReceiverTransactionDate() {
    if (related != null) {
      return related!.dateTime.value;
    }
    return null;
  }

  //---------------------------------------------

  //---------------------------------------------
  // Accounts
  Account? getSenderAccount() {
    return getSenderTransaction()?.getAccount();
  }

  //---------------------------------------------
  // Account Names
  String getSenderAccountName() {
    return (getSenderAccount()?.name.value) ?? '<account not found>';
  }

  //---------------------------------------------
  // Transactions
  Transaction? getSenderTransaction() {
    return source;
  }

  String getTroubleshoot() {
    String status = '';
    if (isOrphan) {
      status += 'Orphan';
    }
    int dateSpread = dateSpreadBetweenSendingAndReceiving().abs();

    if (dateSpread > 2) {
      if (status.isNotEmpty) {
        status += ', ';
      }
      status += '$dateSpread days';
    }
    return status;
  }

// NOTE: we do not support a transfer from one split to another split, this is a pretty unlikely scenario,
// although it would be possible, if you withdraw 500 cash from one account, then combine $100 of that with
// a check for $200 in a single deposit, then the $100 is split on the source as a "transfer" to the
// deposited account, and the $300 deposit is split between the cash and the check.  Like I said, pretty unlikely.
}
