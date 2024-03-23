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

  /// ID
  /// SQLite  0|Id|bigint|0||1
  FieldId<TransactionExtra> id = FieldId<TransactionExtra>(
    valueForSerialization: (final TransactionExtra instance) => instance.uniqueId,
  );

  // 1
  FieldInt<TransactionExtra> transaction = FieldInt<TransactionExtra>(
    serializeName: 'Transaction',
    valueForSerialization: (final TransactionExtra instance) => instance.transaction.value,
  );

  // 2
  FieldInt<TransactionExtra> taxYear = FieldInt<TransactionExtra>(
    serializeName: 'TaxYear',
    valueForSerialization: (final TransactionExtra instance) => instance.taxYear.value,
  );

  // 4
  FieldDate<TransactionExtra> taxDate = FieldDate<TransactionExtra>(
    serializeName: 'TaxDate',
    valueForSerialization: (final TransactionExtra instance) => instance.taxDate.value,
  );

  /// Constructor
  TransactionExtra({
    // 0
    required int id,
    // 1
    required int transaction,
    // 2
    required int taxYear,
    // 3
    required DateTime? taxDate,
  }) {
    this.id.value = id;
    this.transaction.value = transaction;
    this.taxYear.value = taxYear;
    this.taxDate.value = taxDate;
  }
}
