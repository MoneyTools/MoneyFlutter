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
  static Fields<Security>? fields;

  static getFields() {
    if (fields == null) {
      Security.fromJson({});
    }
    return fields;
  }

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  // 0
  FieldId id = FieldId(
    valueFromInstance: (final MoneyObject instance) => (instance as Security).uniqueId,
    valueForSerialization: (final MoneyObject instance) => (instance as Security).uniqueId,
  );

  // 1
  FieldString name = FieldString(
    name: 'Name',
    serializeName: 'Name',
    valueFromInstance: (final MoneyObject instance) => (instance as Security).name.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Security).name.value,
  );

  // 2
  FieldString symbol = FieldString(
    name: 'Symbol',
    serializeName: 'Symbol',
    valueFromInstance: (final MoneyObject instance) => (instance as Security).symbol.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Security).symbol.value,
  );

  // 3
  FieldAmount price = FieldAmount(
    name: 'Price',
    serializeName: 'Price',
    valueFromInstance: (final MoneyObject instance) => (instance as Security).price.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Security).price.value,
  );

  // 4
  FieldAmount lastPrice = FieldAmount(
    name: 'Last Price',
    serializeName: 'LastPrice',
    valueFromInstance: (final MoneyObject instance) => (instance as Security).lastPrice.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Security).lastPrice.value,
  );

  // 5
  FieldString cuspid = FieldString(
    name: 'CUSPID',
    serializeName: 'CUSPID',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Security).cuspid.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Security).cuspid.value,
  );

  // 6
  FieldInt securityType = FieldInt(
    name: 'Type',
    serializeName: 'Type',
    columnWidth: ColumnWidth.tiny,
    align: TextAlign.center,
    valueFromInstance: (final MoneyObject instance) => (instance as Security).securityType.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Security).securityType.value,
  );

  // 7
  FieldInt taxable = FieldInt(
    name: 'Taxable',
    serializeName: 'Taxable',
    valueFromInstance: (final MoneyObject instance) => (instance as Security).taxable.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Security).taxable.value,
  );

  // 8
  FieldDate priceDate = FieldDate(
    name: 'Date',
    serializeName: 'Date',
    valueFromInstance: (final MoneyObject instance) => (instance as Security).priceDate.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Security).priceDate.value,
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
    fields ??= Fields<Security>(definitions: [
      this.id,
      this.name,
      this.symbol,
      this.price,
      this.cuspid,
      this.securityType,
      this.priceDate,
    ]);
    // Also stash the definition in the instance for fast retrieval later
    fieldDefinitions = fields!.definitions;

    this.id.value = id;
    this.name.value = name;
    this.symbol.value = symbol;
    this.price.value = price;
    this.lastPrice.value = lastPrice;
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
}
