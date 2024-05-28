import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/json_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/splits/splits.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

class Transfer extends MoneyObject {
  static final _fields = Fields<Transfer>();

  static get fields {
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

  @override
  int get uniqueId => source.uniqueId;

  final Transaction source; // the source of the transfer.
  final Transaction? related; // the related transaction

  final num id; // used when the transfer is part of a split
  final MoneySplit? sourceSplit; // the source split, if it is a transfer in a split.
  final MoneySplit? relatedSplit; // the related split, if it is a transfer in a split.

  final bool isOrphan;

  //
  // SENDER
  //
  FieldDate senderTransactionDate = FieldDate(
    importance: 1,
    name: 'Sent on',
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).geSenderTransactionDate(),
  );

  /// Account
  Field<int> senderAccountId = Field<int>(
    importance: 2,
    type: FieldType.text,
    name: 'Sender',
    defaultValue: -1,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).getSenderAccountName(),
  );

  /// Status
  FieldString senderTransactionStatus = FieldString(
    importance: 3,
    name: 'SS',
    align: TextAlign.center,
    columnWidth: ColumnWidth.nano,
    getValueForDisplay: (final MoneyObject instance) =>
        (instance as Transfer).source.status.getValueForDisplay(instance.source),
  );

  /// memo
  FieldString senderTransactionMemo = FieldString(
    importance: 4,
    name: 'Sender memo',
    columnWidth: ColumnWidth.largest,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).getMemoSource(),
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
  Field<int> receiverAccountId = Field<int>(
    importance: 11,
    type: FieldType.text,
    name: 'Recipient account',
    defaultValue: -1,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).getReceiverAccountName(),
  );

  /// Status
  FieldString accountStatusDestination = FieldString(
    importance: 12,
    name: 'RS',
    align: TextAlign.center,
    columnWidth: ColumnWidth.nano,
    getValueForDisplay: (final MoneyObject instance) =>
        (instance as Transfer).source.status.getValueForDisplay(instance.source),
  );

  /// memo
  FieldString memoDestination = FieldString(
    importance: 97,
    name: 'Recipient memo',
    columnWidth: ColumnWidth.largest,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).getMemoDestination(),
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

  /// Transfer amount
  FieldMoney transactionAmount = FieldMoney(
    importance: 99,
    name: 'Amount',
    columnWidth: ColumnWidth.small,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).source.amount.value,
  );

  Transfer({
    required this.id,
    required this.source,
    this.related,
    this.sourceSplit,
    this.relatedSplit,
    required this.isOrphan,
  }) {
    // body of constructor
  }

  factory Transfer.fromJson(final MyJson row) {
    return Transfer(id: -1, source: Transaction(), isOrphan: true);
  }

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  //---------------------------------------------
  // Transactions
  Transaction getSenderTransaction() {
    return source;
  }

  Transaction? getReceiverTransaction() {
    if (related != null) {
      return related!;
    }

    return null;
  }

  //---------------------------------------------

  //---------------------------------------------
  // Accounts
  Account? getSenderAccount() {
    return getSenderTransaction().getAccount();
  }

  Account? getReceiverAccount() {
    if (related != null) {
      return related!.getAccount();
    }
    return null;
  }

  //---------------------------------------------
  // Account Names
  String getSenderAccountName() {
    return (getSenderAccount()?.name.value) ?? '<account not found>';
  }

  String getReceiverAccountName() {
    return (getReceiverAccount()?.name.value) ?? '<account not found>';
  }

  //---------------------------------------------

  //---------------------------------------------
  /// Dates
  DateTime? geSenderTransactionDate() {
    return source.dateTime.value;
  }

  DateTime? getReceiverTransactionDate() {
    if (related != null) {
      return related!.dateTime.value;
    }
    return null;
  }

  DateTime getReceivedDateOrToday() {
    return getReceiverTransactionDate() ?? DateTime.now();
  }

  //---------------------------------------------

  //---------------------------------------------
  // Amounts
  double geSenderTransactionAmount() {
    return source.amount.value.amount;
  }

  double geReceiverTransactionAmount() {
    if (related != null) {
      return related!.amount.value.amount;
    }
    return 0.00;
  }

  //---------------------------------------------

  String evaluatedReceivedDate() {
    return dateToString(getReceivedDateOrToday());
  }

  int dateSpreadBetweenSendingAndReceiving() {
    DateTime dateSent = geSenderTransactionDate() ?? DateTime.now();
    DateTime dateReceived = getReceivedDateOrToday();
    return dateReceived.difference(dateSent).inDays;
  }

  String getMemoSource() {
    return source.memo.value;
  }

  String getMemoDestination() {
    String memos = source.transferSplit.value == -1 ? '' : '[Split:${source.transferSplit.value}] ';
    if (related != null) {
      memos += related!.memo.value;
    }
    return memos;
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

enum TransactionFlags {
  none, // 0
  unaccepted, // 1
  budgeted, // 2
  filler3,
  hasAttachment, // 4
  filler4,
  filler5,
  filler6,
  filler7,
  notDuplicate, // 8
  filler9,
  filler10,
  filler11,
  filler12,
  filler13,
  filler14,
  filler15,
  hasStatement, // 16
}
