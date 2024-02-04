import 'package:money/models/money_objects/money_object.dart';

/*
  SQLite table definition
  0    Id           INT       0                    1
  1    Transaction  bigint    1                    0
  2    TaxYear      INT       1                    0
  3    TaxDate      datetime  0                    0
 */

class TransactionExtra extends MoneyObject {
  @override
  int get uniqueId => id.value;
  @override
  set uniqueId(value) => id.value = value;

  // 0
  FieldId<TransactionExtra> id = FieldId<TransactionExtra>(
    valueForSerialization: (final TransactionExtra instance) => instance.uniqueId,
  );

  // 1
  int transaction;

  // 2
  int taxYear;

  // 4
  int taxDate;

  /// Constructor
  TransactionExtra({
    // 0
    // id
    // 1
    required this.transaction,
    // 2
    required this.taxYear,
    // 3
    required this.taxDate,
  });
}
