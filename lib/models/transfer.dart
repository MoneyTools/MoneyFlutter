import 'package:money/models/splits.dart';
import 'package:money/models/transactions.dart';

class Transfer {
  final num id;
  final Transaction owner; // the source of the transfer.
  final Split ownerSplit; // the source split, if it is a transfer in a split.
  final Transaction transaction; // the related transaction
  final Split split; // the related split, if it is a transfer in a split.

  Transfer({
    required this.id,
    required this.owner,
    required this.ownerSplit,
    required this.transaction,
    required this.split,
  }) {
    //
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
