import 'package:money/helpers/json_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_objects.dart';

class LoanPayment extends MoneyObject<LoanPayment> {
  @override
  int get uniqueId => id.value;

  /// ID
  /// 0|Id|INT|1||0
  DeclareId<LoanPayment> id = DeclareId<LoanPayment>(
    importance: 0,
    valueForSerialization: (final LoanPayment instance) => instance.id.value,
  );

  /// 1|AccountId|INT|1||0
  Declare<LoanPayment, int> accountId = Declare<LoanPayment, int>(
    importance: 1,
    name: 'AccountId',
    serializeName: 'AccountId',
    defaultValue: -1,
    valueFromInstance: (final LoanPayment instance) => Account.getName(instance.accountInstance),
    valueForSerialization: (final LoanPayment instance) => instance.accountId.value,
  );

  /// Date
  /// 2|Date|datetime|1||0
  Declare<LoanPayment, DateTime> date = Declare<LoanPayment, DateTime>(
    importance: 2,
    type: FieldType.date,
    serializeName: 'Date',
    useAsColumn: false,
    defaultValue: DateTime.parse('1970-01-01'),
    valueFromInstance: (final LoanPayment instance) => instance.date.value.toIso8601String(),
    valueForSerialization: (final LoanPayment instance) => instance.date.value.toIso8601String(),
  );

  /// 3
  /// 3|Principal|money|0||0
  DeclareDouble<LoanPayment> principal = DeclareDouble<LoanPayment>(
    importance: 3,
    name: 'Principal',
    serializeName: 'Principal',
    valueFromInstance: (final LoanPayment instance) => instance.principal.value,
    valueForSerialization: (final LoanPayment instance) => instance.principal.value,
  );

  /// Interest
  /// 4|Interest|money|0||0
  DeclareDouble<LoanPayment> interest = DeclareDouble<LoanPayment>(
    importance: 4,
    name: 'Interest',
    serializeName: 'Interest',
    valueFromInstance: (final LoanPayment instance) => instance.interest.value,
    valueForSerialization: (final LoanPayment instance) => instance.interest.value,
  );

  // 5
  // 5|Memo|nvarchar(255)|0||0
  Declare<LoanPayment, String> memo = Declare<LoanPayment, String>(
    importance: 99,
    type: FieldType.text,
    name: 'Memo',
    serializeName: 'Memo',
    defaultValue: '',
    valueFromInstance: (final LoanPayment instance) => instance.memo.value,
    valueForSerialization: (final LoanPayment instance) => instance.memo.value,
  );

  // Not persisted
  Account? accountInstance;

  LoanPayment({
    required final int accountId,
    required final DateTime date,
    required final double principal,
    required final double interest,
    required final String memo,
  }) {
    this.accountId.value = accountId;
    accountInstance = Data().accounts.get(this.accountId.value);
    this.date.value = date;
    this.principal.value = principal;
    this.interest.value = interest;
  }

  /// Constructor from a SQLite row
  factory LoanPayment.fromSqlite(final Json row) {
    return LoanPayment(
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
    )..id.value = jsonGetInt(row, 'Id');
  }
}
