import 'package:money/core/helpers/json_helper.dart';
import 'package:money/data/models/money_objects/money_object.dart';

/*
  SQLite table definition
  0    Id           INT       0                    1
  1    Transaction  bigint    1                    0
  2    TaxYear      INT       1                    0
  3    TaxDate      datetime  0                    0
 */

class TransactionExtra extends MoneyObject {
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
    this.fieldId.value = id;
    this.fieldTransaction.value = transaction;
    this.fieldTaxYear.value = taxYear;
    this.fieldTaxDate.value = taxDate;
  }

  factory TransactionExtra.fromJson(final MyJson row) {
    final TransactionExtra t = TransactionExtra(
      // id
      id: row.getInt('Id', -1),
      // Transaction Id
      transaction: row.getInt('Transaction', -1),
      // Tax Year
      taxYear: row.getInt('TaxYear'),
      // Tax Date
      taxDate: row.getDate('TaxDate'),
    );

    return t;
  }

  /// ID
  /// SQLite  0|Id|bigint|0||1
  FieldId fieldId = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as TransactionExtra).uniqueId,
  );

  // 4
  FieldDate fieldTaxDate = FieldDate(
    serializeName: 'TaxDate',
    getValueForSerialization: (final MoneyObject instance) => (instance as TransactionExtra).fieldTaxDate.value,
  );

  // 2
  FieldInt fieldTaxYear = FieldInt(
    serializeName: 'TaxYear',
    getValueForSerialization: (final MoneyObject instance) => (instance as TransactionExtra).fieldTaxYear.value,
  );

  // 1
  FieldInt fieldTransaction = FieldInt(
    serializeName: 'Transaction',
    getValueForSerialization: (final MoneyObject instance) => (instance as TransactionExtra).fieldTransaction.value,
  );

  @override
  int get uniqueId => fieldId.value;

  @override
  set uniqueId(value) => fieldId.value = value;

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  static final _fields = Fields<TransactionExtra>();

  static Fields<TransactionExtra> get fields {
    if (_fields.isEmpty) {
      final tmp = TransactionExtra.fromJson({});
      _fields.setDefinitions([
        tmp.fieldId,
        tmp.fieldTaxDate,
        tmp.fieldTaxYear,
        tmp.fieldTransaction,
      ]);
    }
    return _fields;
  }
}
