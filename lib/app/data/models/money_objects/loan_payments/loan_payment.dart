// ignore_for_file: unnecessary_this

import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/currencies/currency.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_item_card.dart';

class LoanPayment extends MoneyObject {
  LoanPayment({
    required final int id,
    required final int accountId,
    required final DateTime? date,
    required final String memo,
    required final double principal,
    required final double interest,
    final String reference = '',
  }) {
    this.id.value = id;
    this.accountId.value = accountId;
    accountInstance = Data().accounts.get(this.accountId.value);
    this.date.value = date;
    this.memo.value = memo;
    this.principal.value.setAmount(principal);
    this.interest.value.setAmount(interest);
    this.reference.value = reference;

    buildFieldsAsWidgetForSmallScreen = () => MyListItemAsCard(
          leftTopAsString: Account.getName(accountInstance),
          rightTopAsString: Currency.getAmountAsStringUsingCurrency(principal),
          rightBottomAsString: Currency.getAmountAsStringUsingCurrency(interest),
        );
  }

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
  static final Fields<LoanPayment> _fields = Fields<LoanPayment>();

  static Fields<LoanPayment> get fields {
    if (_fields.isEmpty) {
      final tmpInstance = LoanPayment.fromJson({});
      _fields.setDefinitions([
        tmpInstance.id,
        tmpInstance.date,
        tmpInstance.accountId,
        tmpInstance.memo,
        tmpInstance.reference,
        tmpInstance.rate,
        tmpInstance.interest,
        tmpInstance.principal,
        tmpInstance.balance,
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
    // This can be improved
    return 'Loan $uniqueId';
  }

  /// ID
  /// 0|Id|INT|1||0
  FieldId id = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as LoanPayment).uniqueId,
  );

  /// 1|AccountId|INT|1||0
  Field<int> accountId = Field<int>(
    importance: 2,
    name: 'Account',
    serializeName: 'AccountId',
    defaultValue: -1,
    type: FieldType.text,
    getValueForDisplay: (final MoneyObject instance) => Account.getName((instance as LoanPayment).accountInstance),
    getValueForSerialization: (final MoneyObject instance) => (instance as LoanPayment).accountId.value,
  );

  /// Date
  /// 2|Date|datetime|1||0
  FieldDate date = FieldDate(
    importance: 1,
    serializeName: 'Date',
    useAsColumn: true,
    getValueForDisplay: (final MoneyObject instance) => (instance as LoanPayment).date.value,
    getValueForSerialization: (final MoneyObject instance) =>
        dateToIso8601OrDefaultString((instance as LoanPayment).date.value),
  );

  /// 3
  /// 3|Principal|money|0||0
  FieldMoney principal = FieldMoney(
    name: 'Principal',
    serializeName: 'Principal',
    getValueForDisplay: (final MoneyObject instance) => (instance as LoanPayment).principal.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as LoanPayment).principal.value.toDouble(),
  );

  /// Interest
  /// 4|Interest|money|0||0
  FieldMoney interest = FieldMoney(
    name: 'Interest',
    serializeName: 'Interest',
    getValueForDisplay: (final MoneyObject instance) => (instance as LoanPayment).interest.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as LoanPayment).interest.value.toDouble(),
  );

  // 5
  // 5|Memo|nvarchar(255)|0||0
  Field<String> memo = Field<String>(
    importance: 3,
    type: FieldType.text,
    name: 'Memo',
    serializeName: 'Memo',
    useAsColumn: false,
    defaultValue: '',
    getValueForDisplay: (final MoneyObject instance) => (instance as LoanPayment).memo.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as LoanPayment).memo.value,
  );

  // Not persisted
  Account? accountInstance;

  FieldMoney payment = FieldMoney(
    name: 'Payment',
    getValueForDisplay: (final MoneyObject instance) => (instance as LoanPayment)._totalPrincipalAndInterest,
  );

  FieldString reference = FieldString(
    name: 'Reference',
    columnWidth: ColumnWidth.largest,
    getValueForDisplay: (final MoneyObject instance) => (instance as LoanPayment).reference.value,
  );

  double get _totalPrincipalAndInterest => this.principal.value.toDouble() + this.interest.value.toDouble();

  FieldPercentage rate = FieldPercentage(
    name: 'Rate %',
    getValueForDisplay: (final MoneyObject instance) => (instance as LoanPayment).getRate(),
    importance: 98,
  );

  double getRate() {
    double previouseBalance = this.balance.value.toDouble() - this.principal.value.toDouble();
    if (previouseBalance == 0) {
      return 0.00;
    }

    // Calculate the monthly interest rate
    double annualInterestRate = (this.interest.value.toDouble() * 12) // Convert to annual interest rate
        /
        previouseBalance;

    return annualInterestRate.abs();
  }

  FieldMoney balance = FieldMoney(
    name: 'Balance',
    getValueForDisplay: (final MoneyObject instance) => (instance as LoanPayment).balance.value.toDouble(),
    getValueForSerialization: (final MoneyObject instance) => (instance as LoanPayment).balance.value.toDouble(),
    importance: 99,
  );

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;
}
