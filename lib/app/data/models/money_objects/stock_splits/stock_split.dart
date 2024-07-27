import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/data/storage/data/data.dart';

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
  StockSplit({
    required DateTime? date,
    required int security,
    required int numerator,
    required int denominator,
  }) {
    this.date.value = date;
    this.security.value = security;
    this.numerator.value = numerator;
    this.denominator.value = denominator;
  }

  /// Constructor from a SQLite row
  factory StockSplit.fromJson(final MyJson row) {
    return StockSplit(
      date: row.getDate('Date'),
      security: row.getInt('Security'),
      numerator: row.getInt('Numerator'),
      denominator: row.getInt('Denominator'),
    )..id.value = row.getInt('Id', -1);
  }

  FieldDate date = FieldDate(
    name: 'Date',
    serializeName: 'Date',
    getValueForDisplay: (final MoneyObject instance) => (instance as StockSplit).date.value,
    getValueForSerialization: (final MoneyObject instance) => dateToSqliteFormat((instance as StockSplit).date.value),
  );

  FieldInt denominator = FieldInt(
    name: 'Denominator',
    serializeName: 'Denominator',
    getValueForDisplay: (final MoneyObject instance) => (instance as StockSplit).denominator.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as StockSplit).denominator.value,
  );

  FieldId id = FieldId(
    getValueForDisplay: (final MoneyObject instance) => (instance as StockSplit).uniqueId,
    getValueForSerialization: (final MoneyObject instance) => instance.uniqueId,
  );

  FieldInt numerator = FieldInt(
    name: 'Numerator',
    serializeName: 'Numerator',
    getValueForDisplay: (final MoneyObject instance) => (instance as StockSplit).numerator.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as StockSplit).numerator.value,
  );

  FieldInt security = FieldInt(
    name: 'Security',
    serializeName: 'Security',
    getValueForDisplay: (final MoneyObject instance) => (instance as StockSplit).security.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as StockSplit).security.value,
  );

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  @override
  String getRepresentation() {
    return Data().securities.getSymbolFromId(security.value);
  }

  @override
  String toString() {
    return '${date.value}|${security.value}|${numerator.value} for ${denominator.value}';
  }

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  static final Fields<StockSplit> _fields = Fields<StockSplit>();

  static Fields<StockSplit> get fields {
    if (_fields.isEmpty) {
      final tmp = StockSplit.fromJson({});
      _fields.setDefinitions([
        tmp.id,
        tmp.date,
        tmp.security,
        tmp.numerator,
        tmp.denominator,
      ]);
    }
    return _fields;
  }
}
