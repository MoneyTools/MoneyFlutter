import 'package:money/models/money_objects/money_object.dart';

/*
  SQLite table definition
  0    Id           INT       0                    1
  1    Transaction  bigint    1                    0
  2    TaxYear      INT       1                    0
  3    TaxDate      datetime  0                    0
 */

class TransactionExtra extends MoneyObject<TransactionExtra> {
  @override
  int get uniqueId => id.value;

  // 0
  Field<TransactionExtra, int> id = Field<TransactionExtra, int>(
    importance: 0,
    serializeName: 'Id',
    defaultValue: -1,
    useAsColumn: false,
    valueForSerialization: (final TransactionExtra instance) => instance.id.value,
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
