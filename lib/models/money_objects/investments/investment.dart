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

  /// Id
  //// 0    Id              bigint  0                    1
  FieldId<Investment> id = FieldId<Investment>(
    valueForSerialization: (final Investment instance) => instance.uniqueId,
  );

  /// 1    Security        INT     1                    0
  FieldInt<Investment> security = FieldInt<Investment>(
    importance: 1,
    name: 'Security',
    serializeName: 'Security',
    valueFromInstance: (final Investment instance) => instance.security.value,
    valueForSerialization: (final Investment instance) => instance.security.value,
  );

  /// 2    UnitPrice       money   1                    0
  FieldAmount<Investment> unitPrice = FieldAmount<Investment>(
    importance: 3,
    name: 'UnitPrice',
    serializeName: 'UnitPrice',
    valueFromInstance: (final Investment instance) => instance.unitPrice.value,
    valueForSerialization: (final Investment instance) => instance.unitPrice.value,
  );

  /// 3    Units           money   0                    0
  FieldAmount<Investment> units = FieldAmount<Investment>(
    importance: 2,
    name: 'Units',
    serializeName: 'Units',
    valueFromInstance: (final Investment instance) => instance.units.value,
    valueForSerialization: (final Investment instance) => instance.units.value,
  );

  /// 4    Commission      money   0                    0
  FieldAmount<Investment> commission = FieldAmount<Investment>(
    name: 'Commission',
    serializeName: 'Commission',
    valueFromInstance: (final Investment instance) => instance.commission.value,
    valueForSerialization: (final Investment instance) => instance.commission.value,
  );

  /// 5    MarkUpDown      money   0                    0
  FieldAmount<Investment> markUpDown = FieldAmount<Investment>(
    name: 'MarkUpDown',
    serializeName: 'MarkUpDown',
    valueFromInstance: (final Investment instance) => instance.markUpDown.value,
    valueForSerialization: (final Investment instance) => instance.markUpDown.value,
  );

  /// 6    Taxes           money   0                    0
  FieldAmount<Investment> taxes = FieldAmount<Investment>(
    name: 'Taxes',
    serializeName: 'Taxes',
    valueFromInstance: (final Investment instance) => instance.taxes.value,
    valueForSerialization: (final Investment instance) => instance.taxes.value,
  );

  /// 7    Fees            money   0                    0
  FieldAmount<Investment> fees = FieldAmount<Investment>(
    name: 'Fees',
    serializeName: 'Fees',
    valueFromInstance: (final Investment instance) => instance.fees.value,
    valueForSerialization: (final Investment instance) => instance.fees.value,
  );

  /// 8    Load            money   0                    0
  FieldAmount<Investment> load = FieldAmount<Investment>(
    name: 'Load',
    serializeName: 'Load',
    valueFromInstance: (final Investment instance) => instance.load.value,
    valueForSerialization: (final Investment instance) => instance.load.value,
  );

  /// 9    InvestmentType  INT     1                    0
  FieldInt<Investment> investmentType = FieldInt<Investment>(
    name: 'InvestmentType',
    serializeName: 'InvestmentType',
    valueFromInstance: (final Investment instance) => instance.investmentType.value,
    valueForSerialization: (final Investment instance) => instance.investmentType.value,
  );

  /// 10   TradeType       INT     0                    0
  FieldInt<Investment> tradeType = FieldInt<Investment>(
    name: 'TradeType',
    serializeName: 'TradeType',
    valueFromInstance: (final Investment instance) => instance.tradeType.value,
    valueForSerialization: (final Investment instance) => instance.tradeType.value,
  );

  /// 11   TaxExempt       bit     0                    0
  FieldInt<Investment> taxExempt = FieldInt<Investment>(
    name: 'TaxExempt',
    serializeName: 'TaxExempt',
    valueFromInstance: (final Investment instance) => instance.taxExempt.value,
    valueForSerialization: (final Investment instance) => instance.taxExempt.value,
  );

  /// 12   Withholding     money   0                    0
  FieldAmount<Investment> withholding = FieldAmount<Investment>(
    name: 'Withholding',
    serializeName: 'Withholding',
    valueFromInstance: (final Investment instance) => instance.withholding.value,
    valueForSerialization: (final Investment instance) => instance.withholding.value,
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
      id: row.getInt('Id'),
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
