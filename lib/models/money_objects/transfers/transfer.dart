import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/splits/splits.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

class Transfer extends MoneyObject {
  @override
  int get uniqueId => source.uniqueId;

  final Transaction source; // the source of the transfer.
  final Transaction? related; // the related transaction

  final num id; // used when the transfer is part of a split
  final Split? sourceSplit; // the source split, if it is a transfer in a split.
  final Split? relatedSplit; // the related split, if it is a transfer in a split.

  final bool isOrphan;

  //
  // SENDER
  //
  FieldDate<Transfer> senderTransactionDate = FieldDate<Transfer>(
    importance: 1,
    name: 'Sent on',
    valueFromInstance: (final Transfer instance) => getDateAsText(instance.geSenderTransactionDate()),
    sort: (final Transfer a, final Transfer b, final bool ascending) =>
        sortByDate(a.geSenderTransactionDate(), b.geSenderTransactionDate(), ascending),
  );

  /// Account
  Field<Transfer, int> senderAccountId = Field<Transfer, int>(
    importance: 2,
    type: FieldType.text,
    name: 'Sender',
    defaultValue: -1,
    valueFromInstance: (final Transfer instance) => instance.getSenderAccountName(),
  );

  /// Status
  FieldString<Transfer> senderTransactionStatus = FieldString<Transfer>(
    importance: 3,
    name: 'SS',
    align: TextAlign.center,
    columnWidth: ColumnWidth.nano,
    valueFromInstance: (final Transfer instance) => instance.source.status.valueFromInstance(instance.source),
  );

  /// memo
  FieldString<Transfer> senderTransactionMemo = FieldString<Transfer>(
    importance: 4,
    name: 'Sender memo',
    columnWidth: ColumnWidth.largest,
    valueFromInstance: (final Transfer instance) => instance.getMemoSource(),
  );

  //
  // RECEIVED
  //

  // Date received
  FieldDate<Transfer> receiverTransactionDate = FieldDate<Transfer>(
    importance: 10,
    name: 'Date Received',
    valueFromInstance: (final Transfer instance) => instance.evaluatedReceivedDate(),
  );

  /// Account
  Field<Transfer, int> receiverAccountId = Field<Transfer, int>(
    importance: 11,
    type: FieldType.text,
    name: 'Recipient account',
    defaultValue: -1,
    valueFromInstance: (final Transfer instance) => instance.getReceiverAccountName(),
  );

  /// Status
  FieldString<Transfer> accountStatusDestination = FieldString<Transfer>(
    importance: 12,
    name: 'RS',
    align: TextAlign.center,
    columnWidth: ColumnWidth.nano,
    valueFromInstance: (final Transfer instance) => instance.source.status.valueFromInstance(instance.source),
  );

  /// memo
  FieldString<Transfer> memoDestination = FieldString<Transfer>(
    importance: 97,
    name: 'Recipient memo',
    columnWidth: ColumnWidth.largest,
    valueFromInstance: (final Transfer instance) => instance.getMemoDestination(),
  );

  ///
  /// Common
  ///

  /// Troubleshoot
  FieldString<Transfer> troubleshoot = FieldString<Transfer>(
    importance: 98,
    name: 'Troubleshoot',
    valueFromInstance: (final Transfer instance) => instance.getTroubleshoot(),
  );

  /// Transfer amount
  FieldAmount<Transfer> transactionAmount = FieldAmount<Transfer>(
    importance: 99,
    name: 'Amount',
    columnWidth: ColumnWidth.small,
    valueFromInstance: (final Transfer instance) => instance.source.amount.value,
  );

  Transfer({
    required this.id,
    required this.source,
    this.related,
    this.sourceSplit,
    this.relatedSplit,
    required this.isOrphan,
  });

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
  // Dates
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
    return source.amount.value;
  }

  double geReceiverTransactionAmount() {
    if (related != null) {
      return related!.amount.value;
    }
    return 0.00;
  }

  //---------------------------------------------

  String evaluatedReceivedDate() {
    return getDateAsText(getReceivedDateOrToday());
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
