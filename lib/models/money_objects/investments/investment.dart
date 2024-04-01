import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';

enum InvestmentType {
  add,
  remove,
  buy,
  sell,
  non,
  dividend,
}

class Investment extends MoneyObject {
  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  @override
  String getRepresentation() {
    // TODO
    return security.value.toString();
  }

  /// Id
  //// 0    Id              bigint  0                    1
  FieldId id = FieldId(
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).uniqueId,
  );

  /// 1    Security        INT     1                    0
  FieldInt security = FieldInt(
    importance: 1,
    name: 'Security',
    serializeName: 'Security',
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).security.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).security.value,
  );

  /// 2    UnitPrice       money   1                    0
  FieldAmount unitPrice = FieldAmount(
    importance: 3,
    name: 'UnitPrice',
    serializeName: 'UnitPrice',
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).unitPrice.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).unitPrice.value,
  );

  /// 3    Units           money   0                    0
  FieldAmount units = FieldAmount(
    importance: 2,
    name: 'Units',
    serializeName: 'Units',
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).units.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).units.value,
  );

  /// 4    Commission      money   0                    0
  FieldAmount commission = FieldAmount(
    name: 'Commission',
    serializeName: 'Commission',
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).commission.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).commission.value,
  );

  /// 5    MarkUpDown      money   0                    0
  FieldAmount markUpDown = FieldAmount(
    name: 'MarkUpDown',
    serializeName: 'MarkUpDown',
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).markUpDown.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).markUpDown.value,
  );

  /// 6    Taxes           money   0                    0
  FieldAmount taxes = FieldAmount(
    name: 'Taxes',
    serializeName: 'Taxes',
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).taxes.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).taxes.value,
  );

  /// 7    Fees            money   0                    0
  FieldAmount fees = FieldAmount(
    name: 'Fees',
    serializeName: 'Fees',
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).fees.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).fees.value,
  );

  /// 8    Load            money   0                    0
  FieldAmount load = FieldAmount(
    name: 'Load',
    serializeName: 'Load',
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).load.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).load.value,
  );

  /// 9    InvestmentType  INT     1                    0
  FieldInt investmentType = FieldInt(
    name: 'InvestmentType',
    serializeName: 'InvestmentType',
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).investmentType.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).investmentType.value,
  );

  /// 10   TradeType       INT     0                    0
  FieldInt tradeType = FieldInt(
    name: 'TradeType',
    serializeName: 'TradeType',
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).tradeType.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).tradeType.value,
  );

  /// 11   TaxExempt       bit     0                    0
  FieldInt taxExempt = FieldInt(
    name: 'TaxExempt',
    serializeName: 'TaxExempt',
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).taxExempt.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).taxExempt.value,
  );

  /// 12   Withholding     money   0                    0
  FieldAmount withholding = FieldAmount(
    name: 'Withholding',
    serializeName: 'Withholding',
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).withholding.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).withholding.value,
  );

  Investment({
    required final int id, // 1
    required final int security, // 1
    required final double unitPrice, // 2
    required final double units, // 3
    required final double commission, // 4
    required final double markUpDown, // 5
    required final double taxes, // 6
    required final double fees, // 7
    required final double load, // 8
    required final int investmentType, // 9
    required final int tradeType, // 10
    required final int taxExempt, // 11
    required final double withholding, // 12
  }) {
    this.id.value = id;
    this.security.value = security;
    this.unitPrice.value = unitPrice;
    this.units.value = units;
    this.commission.value = commission;
    this.markUpDown.value = markUpDown;
    this.taxes.value = taxes;
    this.fees.value = fees;
    this.load.value = load;
    this.investmentType.value = investmentType;
    this.tradeType.value = tradeType;
    this.taxExempt.value = taxExempt;
    this.withholding.value = withholding;
  }

  /// Constructor from a SQLite row
  factory Investment.fromJson(final MyJson row) {
    return Investment(
      // 1
      id: row.getInt('Id', -1),
      // 1
      security: row.getInt('Security'),
      // 2
      unitPrice: row.getDouble('UnitPrice'),
      // 3
      units: row.getDouble('Units'),
      // 4
      commission: row.getDouble('Commission'),
      // 5
      markUpDown: row.getDouble('MarkUpDown'),
      // 6
      taxes: row.getDouble('Taxes'),
      // 7
      fees: row.getDouble('Fees'),
      // 8
      load: row.getDouble('Load'),
      // 9
      investmentType: row.getInt('InvestmentType'),
      // 10
      tradeType: row.getInt('TradeType'),
      // 11
      taxExempt: row.getInt('TaxExempt'),
      // 12
      withholding: row.getDouble('Withholding'),
    );
  }
}
