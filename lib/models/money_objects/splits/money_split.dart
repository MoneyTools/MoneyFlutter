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

class MoneySplit extends MoneyObject {
  static final _fields = Fields<MoneySplit>();

  static get fields {
    if (_fields.isEmpty) {
      final tmp = MoneySplit.fromJson({});
      _fields.setDefinitions([
        tmp.payeeId,
        tmp.categoryId,
        tmp.memo,
        tmp.amount,
      ]);
    }
    return _fields;
  }

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  // 0
  FieldInt transactionId = FieldInt(
    name: 'Transaction',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as MoneySplit).transactionId.value,
  );

  // 1
  FieldId id = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as MoneySplit).uniqueId,
  );

  // 2
  FieldInt categoryId = FieldInt(
    name: 'Category',
    type: FieldType.text,
    align: TextAlign.left,
    getValueForDisplay: (final MoneyObject instance) =>
        Data().categories.getNameFromId((instance as MoneySplit).categoryId.value),
  );

  // 3
  FieldInt payeeId = FieldInt(
    name: 'Payee',
    type: FieldType.text,
    align: TextAlign.left,
    getValueForDisplay: (final MoneyObject instance) =>
        Data().payees.getNameFromId((instance as MoneySplit).payeeId.value),
  );

  // 4
  FieldMoney amount = FieldMoney(
    name: 'Amount',
    getValueForDisplay: (final MoneyObject instance) => (instance as MoneySplit).amount.value,
  );

  // 5
  FieldInt transferId = FieldInt(
    name: 'Transfer',
    useAsColumn: false,
  );

  // 6
  FieldString memo = FieldString(
    name: 'Memo',
    getValueForDisplay: (final MoneyObject instance) => (instance as MoneySplit).memo.value,
  );

  // 7
  FieldInt flags = FieldInt(
    name: 'Flags',
    columnWidth: ColumnWidth.nano,
    align: TextAlign.center,
    getValueForDisplay: (final MoneyObject instance) => (instance as MoneySplit).flags.value,
  );

  // 8
  FieldDate budgetBalanceDate = FieldDate(
    name: 'Budgeted Date',
    getValueForDisplay: (final MoneyObject instance) => (instance as MoneySplit).budgetBalanceDate.value,
  );

  /// Constructor
  MoneySplit({
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
    this.id.value = id;
    this.transactionId.value = transactionId;
    this.categoryId.value = categoryId;
    this.payeeId.value = payeeId;
    this.amount.value.amount = amount;
    this.transferId.value = transferId;
    this.memo.value = memo;
    this.flags.value = flags;
    this.budgetBalanceDate.value = budgetBalanceDate;
  }

  factory MoneySplit.fromJson(final MyJson row) {
    return MoneySplit(
      // 0
      transactionId: row.getInt('Transaction', -1),
      // 1
      id: row.getInt('Id', -1),
      // 2
      categoryId: row.getInt('Category', -1),
      // 3
      payeeId: row.getInt('Payee', -1),
      // 4
      amount: row.getDouble('Amount'),
      // 5
      transferId: row.getInt('Transfer', -1),
      // 6
      memo: row.getString('Memo'),
      // 7
      flags: row.getInt('Flags'),
      // 8
      budgetBalanceDate: row.getDate('BudgetBalanceDate'),
    );
  }

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;
}
