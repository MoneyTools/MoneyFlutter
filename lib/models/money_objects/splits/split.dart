import 'package:money/models/fields/fields.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/payees/payee.dart';

/*
  SQLite table definition

  0|Transaction|bigint|1||0
  1|Id|INT|1||0
  2|Category|INT|0||0
  3|Payee|INT|0||0
  4|Amount|money|1||0
  5|Transfer|bigint|0||0
  6|Memo|nvarchar(255)|0||0
  7|Flags|INT|0||0
  8|BudgetBalanceDate|datetime|0||0
 */

class Split extends MoneyObject {
  static Fields<Split>? fields;

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  // 0
  FieldInt transactionId = FieldInt(
    name: 'Transaction',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Split).transactionId.value,
  );

  // 1
  FieldId id = FieldId(
    valueForSerialization: (final MoneyObject instance) => (instance as Split).uniqueId,
  );

  // 2
  FieldInt categoryId = FieldInt(
    name: 'Category',
    type: FieldType.text,
    align: TextAlign.left,
    valueFromInstance: (final MoneyObject instance) =>
        Data().categories.getNameFromId((instance as Split).categoryId.value),
  );

  // 3
  FieldInt payeeId = FieldInt(
    name: 'Payee',
    type: FieldType.text,
    align: TextAlign.left,
    valueFromInstance: (final MoneyObject instance) => Data().payees.getNameFromId((instance as Split).payeeId.value),
  );

  // 4
  FieldAmount amount = FieldAmount(
    name: 'Amount',
    valueFromInstance: (final MoneyObject instance) => (instance as Split).amount.value,
  );

  // 5
  FieldInt transferId = FieldInt(
    name: 'Transfer',
    useAsColumn: false,
  );

  // 6
  FieldString memo = FieldString(
    name: 'Memo',
    valueFromInstance: (final MoneyObject instance) => (instance as Split).memo.value,
  );

  // 7
  FieldInt flags = FieldInt(
    name: 'Flags',
    columnWidth: ColumnWidth.nano,
    align: TextAlign.center,
    valueFromInstance: (final MoneyObject instance) => (instance as Split).flags.value,
  );

  // 8
  FieldDate budgetBalanceDate = FieldDate(
    name: 'Budgeted Date',
    valueFromInstance: (final MoneyObject instance) => (instance as Split).budgetBalanceDate.value,
  );

  /// Constructor
  Split({
    // 1
    required int id,
    // 0
    required int transactionId,
    // 2
    required int categoryId,
    // 3
    required int payeeId,
    // 4
    required double amount,
    // 5
    required int transferId,
    // 6
    required String memo,
    // 7
    required int flags,
    // 8
    required DateTime? budgetBalanceDate,
  }) {
    fields ??= Fields<Split>(definitions: [
      this.payeeId,
      this.categoryId,
      this.memo,
      this.amount,
    ]);
    // Also stash the definition in the instance for fast retrieval later
    fieldDefinitions = fields!.definitions;

    this.id.value = id;
    this.transactionId.value = transactionId;
    this.categoryId.value = categoryId;
    this.payeeId.value = payeeId;
    this.amount.value = amount;
    this.transferId.value = transferId;
    this.memo.value = memo;
    this.flags.value = flags;
    this.budgetBalanceDate.value = budgetBalanceDate;
  }
}
