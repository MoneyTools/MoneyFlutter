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
  FieldId<Currency> id = FieldId<Currency>(
    importance: 0,
    valueForSerialization: (final Currency instance) => instance.id.value,
  );

  /// 1
  /// 1    Symbol       nchar(20)     1                 0
  FieldString<Currency> symbol = FieldString<Currency>(
    importance: 1,
    name: 'Symbol',
    serializeName: 'Symbol',
    valueFromInstance: (final Currency instance) => instance.symbol.value,
    valueForSerialization: (final Currency instance) => instance.symbol.value,
  );

  /// 2
  /// 2    name       nchar(20)     1                 0
  FieldString<Currency> name = FieldString<Currency>(
    importance: 2,
    name: 'Name',
    serializeName: 'Name',
    valueFromInstance: (final Currency instance) => instance.name.value,
    valueForSerialization: (final Currency instance) => instance.name.value,
  );

  /// 3
  /// 3    Ratio        money         0                 0
  FieldDouble<Currency> ratio = FieldDouble<Currency>(
    importance: 3,
    name: 'Ratio',
    serializeName: 'Ratio',
    valueFromInstance: (final Currency instance) => instance.ratio.value,
    valueForSerialization: (final Currency instance) => instance.ratio.value,
  );

  // 4
  FieldDouble<Currency> lastRatio = FieldDouble<Currency>(
    importance: 4,
    name: 'LastRatio',
    serializeName: 'LastRatio',
    valueFromInstance: (final Currency instance) => instance.lastRatio.value,
    valueForSerialization: (final Currency instance) => instance.lastRatio.value,
  );

  /// 5
  /// 5    CultureCode  nvarchar(80)  0                 0
  FieldString<Currency> cultureCode = FieldString<Currency>(
    name: 'Culture Code',
    serializeName: 'CultureCode',
    valueFromInstance: (final Currency instance) => instance.cultureCode.value,
    valueForSerialization: (final Currency instance) => instance.cultureCode.value,
  );

  Currency({
    required final int id, // 0
    required final String symbol, // 1
    required final String name, // 2
    required final double ratio, // 3
    required final String cultureCode, // 4
    required final double lastRatio, // 5
  }) {
    this.id.value = id;
    this.name.value = name;
    this.symbol.value = symbol;
    this.ratio.value = ratio;
    this.cultureCode.value = cultureCode;
    this.lastRatio.value = lastRatio;
  }

  /// Constructor from a SQLite row
  factory Currency.fromJson(final MyJson row) {
    return Currency(
      // 0
      id: row.getInt('Id'),
      // 1
      symbol: row.getString('Symbol'),
      // 2
      name: row.getString('Name'),
      // 3
      ratio: row.getDouble('Ratio'),
      // 4
      lastRatio: row.getDouble('LastRatio'),
      // 5
      cultureCode: row.getString('CultureCode'),
    );
  }
}
