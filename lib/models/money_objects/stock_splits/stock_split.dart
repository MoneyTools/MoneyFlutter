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

class StockSplit extends MoneyObject {
  @override
  int get uniqueId => id.value;
  @override
  set uniqueId(value) => id.value = value;

  // 0
  FieldId<StockSplit> id = FieldId<StockSplit>(
    valueForSerialization: (final StockSplit instance) => instance.uniqueId,
  );

  // 1
  final DateTime? date;

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
  factory StockSplit.fromJson(final MyJson row) {
    return StockSplit(
      // 0
      // id
      // 1
      date: row.getDate('Date'),
      // 2
      security: row.getInt('Security'),
      // 3
      numerator: row.getInt('Numerator'),
      // 4
      denominator: row.getInt('Denominator'),
    )..id.value = row.getInt('Id', -1);
  }
}
