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
class Currency extends MoneyObject {
  // 0
  // int MoneyEntity.Id

  // 1
  final String symbol;

  // 2
  final String name;

  // 3
  final double ratio;

  // 4
  final double lastRatio;

  // 5
  final String cultureCode;

  Currency({
    required super.id,
    required this.symbol,
    required this.name,
    required this.ratio,
    this.lastRatio = 0,
    required this.cultureCode,
  });

  /// Constructor from a SQLite row
  factory Currency.fromSqlite(final Json row) {
    return Currency(
      // 0
      id: jsonGetInt(row, 'Id'),
      // 1
      symbol: jsonGetString(row, 'Symbol'),
      // 2
      name: jsonGetString(row, 'Name'),
      // 3
      ratio: jsonGetDouble(row, 'Ratio'),
      // 4
      lastRatio: jsonGetDouble(row, 'LastRatio'),
      // 5
      cultureCode: jsonGetString(row, 'CultureCode'),
    );
  }

  static FieldDefinitions<Currency> getFieldDefinitions() {
    final FieldDefinitions<Currency> fields = FieldDefinitions<Currency>(definitions: <FieldDefinition<Currency>>[
      MoneyObject.getFieldId<Currency>(),
      FieldDefinition<Currency>(
        useAsColumn: false,
        name: 'Id',
        serializeName: 'id',
        valueFromInstance: (final Currency entity) => entity.id,
      ),
      FieldDefinition<Currency>(
        type: FieldType.text,
        name: 'Symbol',
        serializeName: 'symbol',
        align: TextAlign.left,
        valueFromInstance: (final Currency item) {
          return item.symbol;
        },
        valueForSerialization: (final Currency item) {
          return item.symbol;
        },
        sort: (final Currency a, final Currency b, final bool sortAscending) {
          return sortByString(a.symbol, b.symbol, sortAscending);
        },
      ),
      getFieldForName(),
      FieldDefinition<Currency>(
        type: FieldType.numeric,
        name: 'Ratio',
        serializeName: 'ratio',
        align: TextAlign.left,
        valueFromInstance: (final Currency item) {
          return item.ratio;
        },
        valueForSerialization: (final Currency item) {
          return item.ratio;
        },
        sort: (final Currency a, final Currency b, final bool sortAscending) {
          return sortByValue(a.ratio, b.ratio, sortAscending);
        },
      ),
      FieldDefinition<Currency>(
        type: FieldType.numeric,
        name: 'Last Ratio',
        serializeName: 'last_ratio',
        align: TextAlign.left,
        valueFromInstance: (final Currency item) {
          return item.lastRatio;
        },
        valueForSerialization: (final Currency item) {
          return item.lastRatio;
        },
        sort: (final Currency a, final Currency b, final bool sortAscending) {
          return sortByValue(a.lastRatio, b.lastRatio, sortAscending);
        },
      ),
      FieldDefinition<Currency>(
        type: FieldType.text,
        name: 'CultureCode',
        serializeName: 'culture_code',
        valueFromInstance: (final Currency item) {
          return item.cultureCode;
        },
        valueForSerialization: (final Currency item) {
          return item.cultureCode;
        },
        sort: (final Currency a, final Currency b, final bool sortAscending) {
          return sortByString(a.cultureCode, b.cultureCode, sortAscending);
        },
      ),
    ]);
    return fields;
  }

  static FieldDefinition<Currency> getFieldForName() {
    return FieldDefinition<Currency>(
      type: FieldType.text,
      name: 'Name',
      serializeName: 'name',
      align: TextAlign.left,
      valueFromInstance: (final Currency item) {
        return item.name;
      },
      valueForSerialization: (final Currency item) {
        return item.name;
      },
      sort: (final Currency a, final Currency b, final bool sortAscending) {
        return sortByString(a.name, b.name, sortAscending);
      },
    );
  }
}
