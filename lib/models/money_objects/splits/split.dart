import 'package:money/models/data_io/data.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/money_object.dart';
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
  // 0
  int transactionId;

  // 1
  // MoneyObject.id

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
  DateTime budgetBalanceDate;

  // Not serialized
  Category? categoryInstance;

  Payee? payeeInstance;

  /// Constructor
  Split({
    // 0
    required this.transactionId,
    // 1
    required super.id,
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

  String getCategoryName() {
    if (categoryInstance == null) {
      return '';
    }
    return categoryInstance!.name;
  }

  String getPayeeName() {
    if (payeeInstance == null) {
      return '';
    }
    return payeeInstance!.name;
  }

  static FieldDefinitions<Split> getFieldDefinitions() {
    final FieldDefinitions<Split> fields = FieldDefinitions<Split>(definitions: <FieldDefinition<Split>>[
      FieldDefinition<Split>(
        useAsColumn: false,
        name: 'Id',
        serializeName: 'id',
        type: FieldType.text,
        align: TextAlign.left,
        valueFromInstance: (final Split entity) => entity.id,
        sort: (final Split a, final Split b, final bool sortAscending) {
          return sortByValue(a.id, b.id, sortAscending);
        },
      ),
      FieldDefinition<Split>(
        type: FieldType.numeric,
        useAsColumn: false,
        name: 'CategoryId',
        serializeName: 'categoryId',
        valueFromInstance: (final Split entity) => entity.categoryId,
        sort: (final Split a, final Split b, final bool sortAscending) {
          return sortByValue(a.categoryId, b.categoryId, sortAscending);
        },
      ),
      FieldDefinition<Split>(
        type: FieldType.text,
        name: 'Category',
        valueFromInstance: (final Split item) => item.getCategoryName(),
        sort: (final Split a, final Split b, final bool sortAscending) {
          return sortByString(a.getCategoryName(), b.getCategoryName(), sortAscending);
        },
      ),
      FieldDefinition<Split>(
        type: FieldType.numeric,
        useAsColumn: false,
        name: 'PayeeId',
        serializeName: 'payeeId',
        valueFromInstance: (final Split entity) => entity.payeeId,
        sort: (final Split a, final Split b, final bool sortAscending) {
          return sortByValue(a.payeeId, b.payeeId, sortAscending);
        },
      ),
      FieldDefinition<Split>(
        type: FieldType.text,
        name: 'Payee',
        valueFromInstance: (final Split item) => item.getPayeeName(),
        sort: (final Split a, final Split b, final bool sortAscending) {
          return sortByString(a.getPayeeName(), b.getPayeeName(), sortAscending);
        },
      ),
      FieldDefinition<Split>(
        type: FieldType.text,
        name: 'Memo',
        serializeName: 'memo',
        align: TextAlign.left,
        valueFromInstance: (final Split entity) => entity.memo,
        sort: (final Split a, final Split b, final bool sortAscending) {
          return sortByString(a.memo, b.memo, sortAscending);
        },
      ),
      FieldDefinition<Split>(
        type: FieldType.amount,
        name: 'Amount',
        serializeName: 'amount',
        align: TextAlign.right,
        valueFromInstance: (final Split entity) => entity.amount,
        sort: (final Split a, final Split b, final bool sortAscending) {
          return sortByValue(a.amount, b.amount, sortAscending);
        },
      ),
    ]);
    return fields;
  }
}
