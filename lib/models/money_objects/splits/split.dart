import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/categories/category.dart';
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
  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  // 0
  int transactionId;

  // 1
  FieldId id = FieldId(
    valueForSerialization: (final MoneyObject instance) => (instance as Split).uniqueId,
  );

  // 2
  int categoryId;

  // 3
  int payeeId;

  // 4
  double amount;

  // 5
  int transferId;

  // 6
  String memo;

  // 7
  int flags;

  // 8
  DateTime? budgetBalanceDate;

  // Not serialized
  Category? categoryInstance;

  Payee? payeeInstance;

  /// Constructor
  Split({
    // 0
    required this.transactionId,
    // 1
    // id
    // 2
    required this.categoryId,
    // 3
    required this.payeeId,
    // 4
    required this.amount,
    // 5
    required this.transferId,
    // 6
    required this.memo,
    // 7
    required this.flags,
    // 8
    required this.budgetBalanceDate,
  }) {
    categoryInstance = Data().categories.get(categoryId);
    payeeInstance = Data().payees.get(payeeId);
  }
}
