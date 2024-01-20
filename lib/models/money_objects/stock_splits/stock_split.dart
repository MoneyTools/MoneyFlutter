import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';

/*
  cid  name         type      notnull  dflt_value  pk
  ---  -----------  --------  -------  ----------  --
  0    Id           bigint    0                    1
  1    Date         datetime  1                    0
  2    Security     INT       1                    0
  3    Numerator    money     1                    0
  4    Denominator  money     1                    0
 */

class StockSplit extends MoneyObject<StockSplit> {
  @override
  int get uniqueId => id.value;

  // 0
  Field<StockSplit, int> id = Field<StockSplit, int>(
    importance: 0,
    serializeName: 'Id',
    defaultValue: -1,
    useAsColumn: false,
    valueForSerialization: (final StockSplit instance) => instance.id.value,
  );

  // 1
  final DateTime date;

  // 2
  final int security;

  // 3
  final int numerator;

  // 4
  final int denominator;

  StockSplit({
    required this.date,
    required this.security,
    required this.numerator,
    required this.denominator,
  });

  /// Constructor from a SQLite row
  factory StockSplit.fromSqlite(final Json row) {
    return StockSplit(
      // 0
      // id
      // 1
      date: jsonGetDate(row, 'Date'),
      // 2
      security: jsonGetInt(row, 'Security'),
      // 3
      numerator: jsonGetInt(row, 'Numerator'),
      // 4
      denominator: jsonGetInt(row, 'Denominator'),
    )..id.value = jsonGetInt(row, 'Id');
  }
}
