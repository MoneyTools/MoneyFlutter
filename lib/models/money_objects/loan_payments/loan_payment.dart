import 'package:money/helpers/json_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_objects.dart';

/*
  0|Id|INT|1||0
  1|AccountId|INT|1||0
  2|Date|datetime|1||0
  3|Principal|money|0||0
  4|Interest|money|0||0
  5|Memo|nvarchar(255)|0||0
 */

class LoanPayment extends MoneyObject {
  // 0
  // int MoneyEntity.Id

  // 1
  final int accountId;

  // 2
  DateTime date;

  // 3
  double principal;

  // 4
  double interest;

  // 5
  String memo;

  // Not persisted
  Account? accountInstance;

  LoanPayment({
    required super.id,
    required this.accountId,
    required this.date,
    required this.principal,
    required this.interest,
    required this.memo,
  }) {
    accountInstance = Data().accounts.get(accountId);
  }

  /// Constructor from a SQLite row
  factory LoanPayment.fromSqlite(final Json row) {
    return LoanPayment(
      // 0
      id: jsonGetInt(row, 'Id'),
      // 1
      accountId: jsonGetInt(row, 'AccountId'),
      // 2
      date: jsonGetDate(row, 'Date'),
      // 3
      principal: jsonGetDouble(row, 'Principal'),
      // 4
      interest: jsonGetDouble(row, 'Interest'),
      // 3
      memo: jsonGetString(row, 'Memo'),
    );
  }

  static FieldDefinition<LoanPayment> getFieldForAccountId() {
    return FieldDefinition<LoanPayment>(
      type: FieldType.numeric,
      name: 'AccountID',
      serializeName: 'accountId',
      valueFromInstance: (final LoanPayment item) {
        return item.memo;
      },
      valueForSerialization: (final LoanPayment item) {
        return item.accountId;
      },
      sort: (final LoanPayment a, final LoanPayment b, final bool sortAscending) {
        return sortByValue(
          a.accountId,
          b.accountId,
          sortAscending,
        );
      },
    );
  }

  static FieldDefinition<LoanPayment> getFieldForAccountName() {
    return FieldDefinition<LoanPayment>(
      type: FieldType.text,
      name: 'Name',
      valueFromInstance: (final LoanPayment item) {
        return item.accountInstance == null ? '' : item.accountInstance!.name;
      },
      sort: (final LoanPayment a, final LoanPayment b, final bool sortAscending) {
        return sortByString(
          a.accountInstance == null ? '' : a.accountInstance!.name,
          b.accountInstance == null ? '' : b.accountInstance!.name,
          sortAscending,
        );
      },
    );
  }

  static FieldDefinition<LoanPayment> getFieldForDate() {
    return FieldDefinition<LoanPayment>(
      type: FieldType.date,
      name: 'Date',
      serializeName: 'date',
      valueFromInstance: (final LoanPayment item) {
        return item.date;
      },
      valueForSerialization: (final LoanPayment item) {
        return item.date;
      },
      sort: (final LoanPayment a, final LoanPayment b, final bool sortAscending) {
        return sortByString(
          a.date,
          b.date,
          sortAscending,
        );
      },
    );
  }

  static FieldDefinition<LoanPayment> getFieldForMemo() {
    return FieldDefinition<LoanPayment>(
      type: FieldType.text,
      name: 'Memo',
      serializeName: 'memo',
      valueFromInstance: (final LoanPayment item) {
        return item.memo;
      },
      valueForSerialization: (final LoanPayment item) {
        return item.memo;
      },
      sort: (final LoanPayment a, final LoanPayment b, final bool sortAscending) {
        return sortByString(
          a.memo,
          b.memo,
          sortAscending,
        );
      },
    );
  }

  static FieldDefinitions<LoanPayment> getFieldDefinitions() {
    final FieldDefinitions<LoanPayment> fields =
        FieldDefinitions<LoanPayment>(definitions: <FieldDefinition<LoanPayment>>[
      MoneyObject.getFieldId<LoanPayment>(),
      getFieldForAccountId(),
      getFieldForDate(),
      getFieldForMemo(),
    ]);
    return fields;
  }
}
