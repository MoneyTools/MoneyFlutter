// ignore_for_file: unnecessary_this

import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/data/models/money_objects/investments/investment_types.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';

/*
  cid  name          type          notnull  dflt_value  pk
  ---  ------------  ------------  -------  ----------  --
  0    Id            INT           0                    1
  1    Name          nvarchar(80)  1                    0
  2    Symbol        nchar(20)     1                    0
  3    Price         money         0                    0
  4    LastPrice     money         0                    0
  5    CUSPID        nchar(20)     0                    0
  6    SECURITYTYPE  INT           0                    0
  7    TAXABLE       tinyint       0                    0
  8    PriceDate     datetime      0                    0
 */

class Security extends MoneyObject {
  Security({
    required int id,
    required String name,
    required String symbol,
    required double price,
    required double lastPrice,
    required String cuspid,
    required int securityType,
    required int taxable,
    required DateTime? priceDate,
  }) {
    this.id.value = id;
    this.name.value = name;
    this.symbol.value = symbol;
    this.price.value.setAmount(price);
    this.lastPrice.value.setAmount(lastPrice);
    this.cuspid.value = cuspid;
    this.securityType.value = securityType;
    this.taxable.value = taxable;
    this.priceDate.value = priceDate;
  }

  /// Constructor from a SQLite row
  factory Security.fromJson(final MyJson row) {
    return Security(
      // 0
      id: row.getInt('Id', -1),
      // 1
      name: row.getString('Name'),
      // 2
      symbol: row.getString('Symbol'),
      // 3
      price: row.getDouble('Price'),
      // 4
      lastPrice: row.getDouble('LastPrice'),
      // 5
      cuspid: row.getString('CUSPID'),
      // 6
      securityType: row.getInt('SecurityType'),
      // 7
      taxable: row.getInt('Taxable'),
      // 8
      priceDate: row.getDate('PriceDate'),
    );
  }

  final FieldMoney holdingValue = FieldMoney(
    name: 'HoldingsValue',
    getValueForDisplay: (final MoneyObject instance) => (instance as Security)._holdingValue,
  );

  FieldMoney activityProfit = FieldMoney(
    name: 'ActivityProfit',
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).activityProfit.value,
  );

  // 5
  FieldString cuspid = FieldString(
    name: 'CUSPID',
    serializeName: 'CUSPID',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).cuspid.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).cuspid.value,
  );

  FieldQuantity holdingShares = FieldQuantity(
    name: 'Holding',
    defaultValue: 0,
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).holdingShares.value,
  );

  // 0
  FieldId id = FieldId(
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).uniqueId,
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).uniqueId,
  );

  // 4
  FieldMoney lastPrice = FieldMoney(
    name: 'Last Price',
    serializeName: 'LastPrice',
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).lastPrice.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).lastPrice.value.toDouble(),
  );

  // 1
  FieldString name = FieldString(
    name: 'Name',
    serializeName: 'Name',
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).name.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).name.value,
    setValue: (final MoneyObject instance, dynamic value) {
      (instance as Security).name.value = value as String;
    },
  );

  // Not persisted fields

  FieldInt numberOfTrades = FieldInt(
    name: 'Trades',
    columnWidth: ColumnWidth.nano,
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).numberOfTrades.value,
  );

  // 3
  FieldMoney price = FieldMoney(
    name: 'Price',
    serializeName: 'Price',
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).price.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).price.value.toDouble(),
  );

  // 8
  FieldDate priceDate = FieldDate(
    name: 'Date',
    serializeName: 'PriceDate',
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).priceDate.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).priceDate.value,
  );

  FieldMoney profit = FieldMoney(
    name: 'Profit',
    getValueForDisplay: (final MoneyObject instance) =>
        (instance as Security).activityProfit.value.toDouble() + instance._holdingValue,
  );

  /* 
    enum SecurityType {
      none,
      bond, // Bonds
      mutualFund,
      equity, // stocks
      moneyMarket, // cash
      etf, // electronically traded fund
      reit, // Real estate investment trust
      futures, // Futures (a type of commodity investment)
      private, // Investment in a private company.
    } 
  */
  // 6
  FieldInt securityType = FieldInt(
    name: 'Type',
    serializeName: 'SECURITYTYPE',
    columnWidth: ColumnWidth.tiny,
    type: FieldType.text,
    align: TextAlign.center,
    getValueForDisplay: (final MoneyObject instance) =>
        getSecurityTypeFromInt((instance as Security).securityType.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).securityType.value,
  );

  // 2
  FieldString symbol = FieldString(
    name: 'Symbol',
    serializeName: 'Symbol',
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).symbol.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).symbol.value,
    setValue: (final MoneyObject instance, dynamic value) {
      (instance as Security).symbol.value = value as String;
    },
  );

  // 7
  FieldInt taxable = FieldInt(
    name: 'Taxable',
    serializeName: 'Taxable',
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).taxable.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).taxable.value,
  );

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  static final _fields = Fields<Security>();

  static Fields<Security> get fields {
    if (_fields.isEmpty) {
      final tmp = Security.fromJson({});
      _fields.setDefinitions([
        tmp.id,
        tmp.name,
        tmp.symbol,
        tmp.price,
        tmp.lastPrice,
        tmp.priceDate,
        tmp.cuspid,
        tmp.securityType,
        tmp.numberOfTrades,
        tmp.holdingShares,
        tmp.holdingValue,
        tmp.activityProfit,
        tmp.profit,
      ]);
    }
    return _fields;
  }

  static String getSecurityTypeFromInt(final int index) {
    if (isIndexInRange(SecurityType.values, index)) {
      return SecurityType.values[index].name;
    }
    return '';
  }

  double get _holdingValue => this.holdingShares.value * this.price.value.toDouble();
}
