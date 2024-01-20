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

class Security extends MoneyObject<Security> {
  @override
  int get uniqueId => id.value;

  // 0
  Declare<Security, int> id = Declare<Security, int>(
    importance: 0,
    serializeName: 'Id',
    defaultValue: -1,
    useAsColumn: false,
    valueForSerialization: (final Security instance) => instance.id.value,
  );

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
    )..id.value = jsonGetInt(row, 'Id');
  }
}
