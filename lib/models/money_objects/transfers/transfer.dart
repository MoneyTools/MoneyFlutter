import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/splits/splits.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

class Transfer extends MoneyObject {
  final Transaction source; // the source of the transfer.
  final Transaction? related; // the related transaction

  final num id; // used when the transfer is part of a split
  final Split? sourceSplit; // the source split, if it is a transfer in a split.
  final Split? relatedSplit; // the related split, if it is a transfer in a split.

  FieldDate<Transfer> dateTime = FieldDate<Transfer>(
    importance: 1,
    name: 'Date Sent',
    valueFromInstance: (final Transfer instance) => getDateAsText(instance.geTransactionDateOfSource()),
    sort: (final Transfer a, final Transfer b, final bool ascending) =>
        sortByDate(a.geTransactionDateOfSource(), b.geTransactionDateOfSource(), ascending),
  );

  /// Account Id Source
  Field<Transfer, int> accountIdSource = Field<Transfer, int>(
    importance: 2,
    type: FieldType.text,
    name: 'Sender',
    defaultValue: -1,
    valueFromInstance: (final Transfer instance) => instance.getAccountSourceName(),
  );

  /// memos Source
  FieldString<Transfer> memoSource = FieldString<Transfer>(
    importance: 3,
    name: 'Sender memo',
    valueFromInstance: (final Transfer instance) => instance.getMemoSource(),
  );

  FieldDate<Transfer> dateTimeReceived = FieldDate<Transfer>(
    importance: 4,
    name: 'Date Received',
    valueFromInstance: (final Transfer instance) => getDateAsText(instance.getReceivedDate()),
    sort: (final Transfer a, final Transfer b, final bool ascending) =>
        sortByDate(a.geTransactionDateOfSource(), b.geTransactionDateOfSource(), ascending),
  );

  /// Account Id Destination
  Field<Transfer, int> accountIdDestination = Field<Transfer, int>(
    importance: 5,
    type: FieldType.text,
    name: 'Recipient account',
    defaultValue: -1,
    valueFromInstance: (final Transfer instance) => instance.getAccountDestinationName(),
  );

  /// memos Source
  FieldString<Transfer> memoDestination = FieldString<Transfer>(
    importance: 6,
    name: 'Recipient memo',
    valueFromInstance: (final Transfer instance) => instance.getMemoDestination(),
  );

  /// Account Id Destination
  FieldAmount<Transfer> transactionAmount = FieldAmount<Transfer>(
    importance: 99,
    name: 'Amount',
    valueFromInstance: (final Transfer instance) => instance.source.amount.value.abs(),
  );

  Transfer({
    required this.id,
    required this.source,
    this.related,
    this.sourceSplit,
    this.relatedSplit,
  });

  Account? getAccountSource() {
    return source.getAccount();
  }

  String getAccountSourceName() {
    if (getAccountSource() != null) {
      return getAccountSource()!.name.value;
    }
    return '<account not found>';
  }

  DateTime? geTransactionDateOfSource() {
    return source.dateTime.value;
  }

  DateTime? geTransactionDateOfDestination() {
    if (related != null) {
      return related!.dateTime.value;
    }
    return null;
  }

  Account? getAccountDestination() {
    if (related != null) {
      return related!.getAccount();
    }
    return null;
  }

  DateTime getReceivedDate() {
    if (related != null) {
      return related!.dateTime.value!;
    }
    return DateTime.now();
  }

  String getAccountDestinationName() {
    if (related != null) {
      if (related!.accountInstance != null) {
        return related!.accountInstance!.name.value;
      }
    }
    return '<account not found>';
  }

  String getMemoSource() {
    return source.memo.value;
  }

  String getMemoDestination() {
    String memos = '';
    if (related != null) {
      memos += related!.memo.value;
    }
    return memos;
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
