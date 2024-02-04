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
  @override
  int get uniqueId => id.value;
  @override
  set uniqueId(value) => id.value = value;

  // 0
  FieldId<Security> id = FieldId<Security>(
    valueForSerialization: (final Security instance) => instance.uniqueId,
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
  final DateTime? priceDate;

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
  factory Security.fromJson(final MyJson row) {
    return Security(
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
    )..id.value = row.getInt('Id');
  }
}
