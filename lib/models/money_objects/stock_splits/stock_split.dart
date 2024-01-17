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
  // 0
  // int MoneyEntity.Id

  // 1
  final DateTime date;

  // 2
  final int security;

  // 3
  final int numerator;

  // 4
  final int denominator;

  StockSplit({
    required super.id,
    required this.date,
    required this.security,
    required this.numerator,
    required this.denominator,
  });

  /// Constructor from a SQLite row
  factory StockSplit.fromSqlite(final Json row) {
    return StockSplit(
      // 0
      id: jsonGetInt(row, 'Id'),
      // 1
      date: jsonGetDate(row, 'Date'),
      // 2
      security: jsonGetInt(row, 'Security'),
      // 3
      numerator: jsonGetInt(row, 'Numerator'),
      // 4
      denominator: jsonGetInt(row, 'Denominator'),
    );
  }

  static FieldDefinitions<StockSplit> getFieldDefinitions() {
    final FieldDefinitions<StockSplit> fields = FieldDefinitions<StockSplit>(definitions: <FieldDefinition<StockSplit>>[
      MoneyObject.getFieldId<StockSplit>(),
      FieldDefinition<StockSplit>(
        type: FieldType.date,
        name: 'Date',
        serializeName: 'date',
        valueFromInstance: (final StockSplit item) {
          return item.date;
        },
        valueForSerialization: (final StockSplit item) {
          return item.date;
        },
        sort: (final StockSplit a, final StockSplit b, final bool sortAscending) {
          return sortByDate(
            a.date,
            b.date,
            sortAscending,
          );
        },
      ),
      getFieldForSecurity(),
    ]);
    return fields;
  }

  static FieldDefinition<StockSplit> getFieldForSecurity() {
    return FieldDefinition<StockSplit>(
      type: FieldType.numeric,
      name: 'Security',
      serializeName: 'security',
      valueFromInstance: (final StockSplit item) {
        return item.security;
      },
      valueForSerialization: (final StockSplit item) {
        return item.security;
      },
      sort: (final StockSplit a, final StockSplit b, final bool sortAscending) {
        return sortByValue(
          a.security,
          b.security,
          sortAscending,
        );
      },
    );
  }
}
