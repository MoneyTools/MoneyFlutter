// ignore_for_file: unnecessary_this

import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';

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
  static final _fields = Fields<Security>();

  static get fields {
    if (_fields.isEmpty) {
      final tmp = Security.fromJson({});
      _fields.setDefinitions([
        tmp.id,
        tmp.name,
        tmp.symbol,
        tmp.price,
        tmp.cuspid,
        tmp.securityType,
        tmp.priceDate,
        tmp.numberOfTrades,
        tmp.outstandingShares,
        tmp.balance,
      ]);
    }
    return _fields;
  }

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  // 0
  FieldId id = FieldId(
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).uniqueId,
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).uniqueId,
  );

  // 1
  FieldString name = FieldString(
    name: 'Name',
    serializeName: 'Name',
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).name.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).name.value,
  );

  // 2
  FieldString symbol = FieldString(
    name: 'Symbol',
    serializeName: 'Symbol',
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).symbol.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).symbol.value,
  );

  // 3
  FieldMoney price = FieldMoney(
    name: 'Price',
    serializeName: 'Price',
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).price.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).price.value.amount,
  );

  // 4
  FieldMoney lastPrice = FieldMoney(
    name: 'Last Price',
    serializeName: 'LastPrice',
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).lastPrice.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).lastPrice.value.amount,
  );

  // 5
  FieldString cuspid = FieldString(
    name: 'CUSPID',
    serializeName: 'CUSPID',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).cuspid.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).cuspid.value,
  );

  // 6
  FieldInt securityType = FieldInt(
    name: 'Type',
    serializeName: 'Type',
    columnWidth: ColumnWidth.tiny,
    align: TextAlign.center,
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).securityType.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).securityType.value,
  );

  // 7
  FieldInt taxable = FieldInt(
    name: 'Taxable',
    serializeName: 'Taxable',
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).taxable.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).taxable.value,
  );

  // 8
  FieldDate priceDate = FieldDate(
    name: 'Date',
    serializeName: 'Date',
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).priceDate.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Security).priceDate.value,
  );

  // Not persisted fields

  FieldInt numberOfTrades = FieldInt(
    name: 'Trades',
    columnWidth: ColumnWidth.nano,
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).numberOfTrades.value,
  );

  FieldQuantity outstandingShares = FieldQuantity(
    name: 'Shares',
    defaultValue: 0,
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).outstandingShares.value,
  );

  FieldMoney balance = FieldMoney(
    name: 'Balance',
    getValueForDisplay: (final MoneyObject instance) => (instance as Security).balance.value,
  );

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
    this.price.value.amount = price;
    this.lastPrice.value.amount = lastPrice;
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

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;
}
