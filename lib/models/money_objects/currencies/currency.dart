import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';

/*
  cid  name         type          notnull  default  pk
  ---  -----------  ------------  -------  -------  --
  0    Id           INT           0                 1 
  1    Symbol       nchar(20)     1                 0 
  2    Name         nvarchar(80)  1                 0 
  3    Ratio        money         0                 0 
  4    LastRatio    money         0                 0 
  5    CultureCode  nvarchar(80)  0                 0 
 */
class Currency extends MoneyObject<Currency> {
  @override
  int get uniqueId => id.value;

  // 0
  Declare<Currency, int> id = Declare<Currency, int>(
    importance: 0,
    serializeName: 'Id',
    defaultValue: -1,
    useAsColumn: false,
    valueForSerialization: (final Currency instance) => instance.id.value,
  );

  // 1
  final String symbol;

  // 2
  final String name;

  // 3
  final double ratio;

  // 4
  final double lastRatio;

  // 5
  Declare<Currency, String> cultureCode = Declare<Currency, String>(
    serializeName: 'CultureCode',
    defaultValue: '',
  );

  Currency({
    required this.symbol,
    required this.name,
    required this.ratio,
    this.lastRatio = 0,
  });

  /// Constructor from a SQLite row
  factory Currency.fromSqlite(final Json row) {
    return Currency(
      // 1
      symbol: jsonGetString(row, 'Symbol'),
      // 2
      name: jsonGetString(row, 'Name'),
      // 3
      ratio: jsonGetDouble(row, 'Ratio'),
      // 4
      lastRatio: jsonGetDouble(row, 'LastRatio'),
      // 5
    )
      ..id.value = jsonGetInt(row, 'Id')
      ..cultureCode.value = jsonGetString(row, 'CultureCode');
  }
}
