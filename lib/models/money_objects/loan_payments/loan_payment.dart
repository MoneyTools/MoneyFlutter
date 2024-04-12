import 'package:money/helpers/date_helper.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/widgets/list_view/list_item_card.dart';

class LoanPayment extends MoneyObject {
  static final Fields<LoanPayment> _fields = Fields<LoanPayment>();

  static get fields {
    if (_fields.isEmpty) {
      final tmpInstance = LoanPayment.fromJson({});
      _fields.setDefinitions([
        tmpInstance.id,
        tmpInstance.accountId,
        tmpInstance.date,
        tmpInstance.memo,
        tmpInstance.principal,
        tmpInstance.interest,
      ]);
    }
    return _fields;
  }

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  @override
  String getRepresentation() {
    // TODO better
    return 'Loan $uniqueId';
  }

  /// ID
  /// 0|Id|INT|1||0
  FieldId id = FieldId(
    valueForSerialization: (final MoneyObject instance) => (instance as LoanPayment).uniqueId,
  );

  /// 1|AccountId|INT|1||0
  Field<int> accountId = Field<int>(
    importance: 1,
    name: 'Account',
    serializeName: 'AccountId',
    defaultValue: -1,
    valueFromInstance: (final MoneyObject instance) => Account.getName((instance as LoanPayment).accountInstance),
    valueForSerialization: (final MoneyObject instance) => (instance as LoanPayment).accountId.value,
  );

  /// Date
  /// 2|Date|datetime|1||0
  FieldDate date = FieldDate(
    importance: 2,
    serializeName: 'Date',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => dateAsIso8601OrDefault((instance as LoanPayment).date.value),
    valueForSerialization: (final MoneyObject instance) => dateAsIso8601OrDefault((instance as LoanPayment).date.value),
  );

  /// 3
  /// 3|Principal|money|0||0
  FieldAmount principal = FieldAmount(
    importance: 98,
    name: 'Principal',
    serializeName: 'Principal',
    valueFromInstance: (final MoneyObject instance) => (instance as LoanPayment).principal.value,
    valueForSerialization: (final MoneyObject instance) => (instance as LoanPayment).principal.value,
  );

  /// Interest
  /// 4|Interest|money|0||0
  FieldAmount interest = FieldAmount(
    importance: 99,
    name: 'Interest',
    serializeName: 'Interest',
    valueFromInstance: (final MoneyObject instance) => (instance as LoanPayment).interest.value,
    valueForSerialization: (final MoneyObject instance) => (instance as LoanPayment).interest.value,
  );

  // 5
  // 5|Memo|nvarchar(255)|0||0
  Field<String> memo = Field<String>(
    importance: 3,
    type: FieldType.text,
    name: 'Memo',
    serializeName: 'Memo',
    defaultValue: '',
    valueFromInstance: (final MoneyObject instance) => (instance as LoanPayment).memo.value,
    valueForSerialization: (final MoneyObject instance) => (instance as LoanPayment).memo.value,
  );

  // Not persisted
  Account? accountInstance;

  LoanPayment({
    required final int id,
    required final int accountId,
    required final DateTime? date,
    required final double principal,
    required final double interest,
    required final String memo,
  }) {
    this.id.value = id;
    this.accountId.value = accountId;
    accountInstance = Data().accounts.get(this.accountId.value);
    this.date.value = date;
    this.principal.value = principal;
    this.interest.value = interest;

    buildFieldsAsWidgetForSmallScreen = () => MyListItemAsCard(
          leftTopAsString: Account.getName(accountInstance),
          rightTopAsString: Currency.getAmountAsStringUsingCurrency(principal),
          rightBottomAsString: Currency.getAmountAsStringUsingCurrency(interest),
        );
  }

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  /// Constructor from a SQLite row
  factory LoanPayment.fromJson(final MyJson row) {
    return LoanPayment(
      // 0
      id: row.getInt('Id', -1),
      // 1
      accountId: row.getInt('AccountId', -1),
      // 2
      date: row.getDate('Date'),
      // 3
      principal: row.getDouble('Principal'),
      // 4
      interest: row.getDouble('Interest'),
      // 3
      memo: row.getString('Memo'),
    );
  }
}
