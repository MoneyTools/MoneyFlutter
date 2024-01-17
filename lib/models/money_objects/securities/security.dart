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
  // 0
  // int MoneyEntity.Id

  // 1
  final String name;

  // 2
  final String symbol;

  // 3
  final double price;

  // 4
  final double lastPrice;

  // 5
  final String cuspid;

  // 6
  final int securityType;

  // 7
  final int taxable;

  // 8
  final DateTime priceDate;

  Security({
    required super.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.lastPrice,
    required this.cuspid,
    required this.securityType,
    required this.taxable,
    required this.priceDate,
  });

  /// Constructor from a SQLite row
  factory Security.fromSqlite(final Json row) {
    return Security(
      // 0
      id: jsonGetInt(row, 'Id'),
      // 1
      name: jsonGetString(row, 'Name'),
      // 2
      symbol: jsonGetString(row, 'Symbol'),
      // 3
      price: jsonGetDouble(row, 'Price'),
      // 4
      lastPrice: jsonGetDouble(row, 'LastPrice'),
      // 5
      cuspid: jsonGetString(row, 'CUSPID'),
      // 6
      securityType: jsonGetInt(row, 'SecurityType'),
      // 7
      taxable: jsonGetInt(row, 'Taxable'),
      // 8
      priceDate: jsonGetDate(row, 'PriceDate'),
    );
  }

  static FieldDefinitions<Security> getFieldDefinitions() {
    final FieldDefinitions<Security> fields = FieldDefinitions<Security>(definitions: <FieldDefinition<Security>>[
      MoneyObject.getFieldId<Security>(),
      FieldDefinition<Security>(
        type: FieldType.date,
        name: 'Date',
        serializeName: 'date',
        valueFromInstance: (final Security item) {
          return item.priceDate;
        },
        valueForSerialization: (final Security item) {
          return item.priceDate;
        },
        sort: (final Security a, final Security b, final bool sortAscending) {
          return sortByDate(
            a.priceDate,
            b.priceDate,
            sortAscending,
          );
        },
      ),
      getFieldForPrice(),
    ]);
    return fields;
  }

  static FieldDefinition<Security> getFieldForPrice() {
    return FieldDefinition<Security>(
      type: FieldType.amount,
      name: 'Security',
      serializeName: 'security',
      valueFromInstance: (final Security item) {
        return item.price;
      },
      valueForSerialization: (final Security item) {
        return item.price;
      },
      sort: (final Security a, final Security b, final bool sortAscending) {
        return sortByValue(
          a.price,
          b.price,
          sortAscending,
        );
      },
    );
  }
}
