import 'dart:ui';

import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/json_helper.dart';
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
  FieldString fieldAccountStatusDestination = FieldString(
    name: 'RS',
    align: TextAlign.center,
    columnWidth: ColumnWidth.nano,
    getValueForDisplay: (final MoneyObject instance) =>
        transactionStatusToLetter((instance as Transfer).related!.fieldStatus.value),
  );

  /// memo
  FieldString fieldMemoDestination = FieldString(
    name: 'Recipient memo',
    columnWidth: ColumnWidth.largest,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).getMemoDestination(),
  );

  /// Account
  Field<int> fieldReceiverAccountId = Field<int>(
    type: FieldType.text,
    name: 'Recipient account',
    defaultValue: -1,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).receiverAccountName,
  );

  //
  // RECEIVED
  //

  /// Date received
  FieldDate fieldReceiverTransactionDate = FieldDate(
    name: 'Date Received',
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).receiverTransactionDate,
  );

  /// Account
  Field<int> fieldSenderAccountId = Field<int>(
    type: FieldType.text,
    name: 'Sender',
    defaultValue: -1,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).senderAccountName,
  );

  //
  // SENDER
  //
  FieldDate fieldSenderTransactionDate = FieldDate(
    name: 'Sent on',
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).geSenderTransactionDate(),
  );

  /// memo
  FieldString fieldSenderTransactionMemo = FieldString(
    name: 'Sender memo',
    columnWidth: ColumnWidth.largest,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).getMemoSource(),
  );

  /// Status
  FieldString fieldSenderTransactionStatus = FieldString(
    name: 'SS',
    align: TextAlign.center,
    columnWidth: ColumnWidth.nano,
    getValueForDisplay: (final MoneyObject instance) =>
        transactionStatusToLetter((instance as Transfer).source!.fieldStatus.value),
  );

  /// Transfer amount
  FieldMoney fieldTransactionAmount = FieldMoney(
    name: 'Amount',
    columnWidth: ColumnWidth.small,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transfer).source!.fieldAmount.value,
  );

  ///
  /// Common
  ///

  /// Troubleshoot
  FieldString fieldTroubleshoot = FieldString(
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
        tmp.fieldSenderTransactionDate,
        tmp.fieldSenderAccountId,
        tmp.fieldSenderTransactionStatus,
        tmp.fieldSenderTransactionMemo,
        tmp.fieldReceiverTransactionDate,
        tmp.fieldReceiverAccountId,
        tmp.fieldAccountStatusDestination,
        tmp.fieldMemoDestination,
        tmp.fieldTroubleshoot,
        tmp.fieldTransactionAmount,
      ]);
    }
    return _fields;
  }

  static Fields<Transfer> get fieldsForColumnView {
    final tmp = Transfer.fromJson({});

    return Fields<Transfer>()
      ..setDefinitions([
        tmp.fieldSenderTransactionDate,
        tmp.fieldSenderAccountId,
        tmp.fieldSenderTransactionStatus,
        tmp.fieldSenderTransactionMemo,
        tmp.fieldReceiverTransactionDate,
        tmp.fieldReceiverAccountId,
        tmp.fieldAccountStatusDestination,
        tmp.fieldMemoDestination,
        tmp.fieldTroubleshoot,
        tmp.fieldTransactionAmount,
      ]);
  }

  double geReceiverTransactionAmount() {
    if (related != null) {
      return related!.fieldAmount.value.toDouble();
    }
    return 0.00;
  }

  //---------------------------------------------

  //---------------------------------------------
  // Amounts
  double geSenderTransactionAmount() {
    return source!.fieldAmount.value.toDouble();
  }

  //---------------------------------------------

  //---------------------------------------------
  /// Dates
  DateTime? geSenderTransactionDate() {
    return source!.fieldDateTime.value;
  }

  String getMemoDestination() {
    String memos = source!.fieldTransferSplit.value == -1 ? '' : '[Split:${source!.fieldTransferSplit.value}] ';
    if (related != null) {
      memos += related!.fieldMemo.value;
    }
    return memos;
  }

  String getMemoSource() {
    return source!.fieldMemo.value;
  }

  DateTime getReceivedDateOrToday() {
    return receiverTransactionDate ?? DateTime.now();
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

  Account? get receiverAccount {
    if (related != null) {
      return related!.account;
    }
    return null;
  }

  String get receiverAccountName => receiverAccount?.fieldName.value ?? '<account not found>';

  Transaction? get receiverTransaction {
    if (related != null) {
      return related!;
    }

    return null;
  }

  DateTime? get receiverTransactionDate {
    if (related != null) {
      return related!.fieldDateTime.value;
    }
    return null;
  }

  //---------------------------------------------

  //---------------------------------------------
  // Sender Account
  Account? get senderAccount {
    return senderTransaction?.account;
  }

  //---------------------------------------------
  // Account Names
  String get senderAccountName {
    return (senderAccount?.fieldName.value) ?? '<account not found>';
  }

  //---------------------------------------------
  // Transactions
  Transaction? get senderTransaction {
    return source;
  }

// NOTE: we do not support a transfer from one split to another split, this is a pretty unlikely scenario,
// although it would be possible, if you withdraw 500 cash from one account, then combine $100 of that with
// a check for $200 in a single deposit, then the $100 is split on the source as a "transfer" to the
// deposited account, and the $300 deposit is split between the cash and the check.  Like I said, pretty unlikely.
}
