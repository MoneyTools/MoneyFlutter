import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/money_object.dart';

/*
  SQLite table definition
  0    Id           INT       0                    1
  1    Transaction  bigint    1                    0
  2    TaxYear      INT       1                    0
  3    TaxDate      datetime  0                    0
 */

class TransactionExtra extends MoneyObject {
  // 0
  // MoneyObject.id

  // 1
  int transaction;

  // 2
  int taxYear;

  // 4
  int taxDate;

  /// Constructor
  TransactionExtra({
    // 0
    required super.id,
    // 1
    required this.transaction,
    // 2
    required this.taxYear,
    // 3
    required this.taxDate,
  });

  static FieldDefinitions<TransactionExtra> getFieldDefinitions() {
    final FieldDefinitions<TransactionExtra> fields =
        FieldDefinitions<TransactionExtra>(definitions: <FieldDefinition<TransactionExtra>>[
      FieldDefinition<TransactionExtra>(
        useAsColumn: false,
        name: 'Id',
        serializeName: 'id',
        type: FieldType.text,
        align: TextAlign.left,
        valueFromInstance: (final TransactionExtra entity) => entity.id,
        sort: (final TransactionExtra a, final TransactionExtra b, final bool sortAscending) {
          return sortByValue(a.id, b.id, sortAscending);
        },
      ),
      FieldDefinition<TransactionExtra>(
        type: FieldType.numeric,
        useAsColumn: false,
        name: 'Transaction',
        serializeName: 'transaction',
        valueFromInstance: (final TransactionExtra entity) => entity.transaction,
        sort: (final TransactionExtra a, final TransactionExtra b, final bool sortAscending) {
          return sortByValue(a.transaction, b.transaction, sortAscending);
        },
      ),
      FieldDefinition<TransactionExtra>(
        type: FieldType.numeric,
        name: 'Tax Year',
        serializeName: 'tax_year',
        valueFromInstance: (final TransactionExtra item) => item.taxYear,
        sort: (final TransactionExtra a, final TransactionExtra b, final bool sortAscending) {
          return sortByString(a.taxYear, b.taxYear, sortAscending);
        },
      ),
      FieldDefinition<TransactionExtra>(
        type: FieldType.numeric,
        name: 'Tax Date',
        serializeName: 'tax_date',
        valueFromInstance: (final TransactionExtra item) => item.taxDate,
        sort: (final TransactionExtra a, final TransactionExtra b, final bool sortAscending) {
          return sortByString(a.taxDate, b.taxDate, sortAscending);
        },
      ),
    ]);
    return fields;
  }
}
