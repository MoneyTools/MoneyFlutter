import 'package:money/helpers/json_helper.dart';
import 'package:money/models/data_io/database/database.dart';
import 'package:money/models/money_objects/money_object.dart';

// exports
export 'package:money/models/money_objects/money_object.dart';
export 'package:money/models/fields/fields.dart';
export 'package:collection/collection.dart';

/// Collection of MoneyObject as both List and Map
class MoneyObjects<T> {
  final List<T> _list = <T>[];
  final Map<num, T> _map = <num, T>{};

  /// Constructor
  MoneyObjects();

  List<T> getList() {
    return _list;
  }

  List<T> getListSortedById() {
    _list.sort((final T a, final T b) {
      return sortByValue(
        (a as MoneyObject<T>).uniqueId,
        (b as MoneyObject<T>).uniqueId,
        true,
      );
    });
    return _list;
  }

  void clear() {
    _list.clear();
  }

  int get length {
    return _list.length;
  }

  void addEntry(final T entry) {
    _list.add(entry);
    _map[(entry as MoneyObject<T>).uniqueId] = entry;
  }

  T? get(final num id) {
    return _map[id];
  }

  /// Must be override by derived class
  String sqlQuery() {
    return 'SELECT * FROM ?';
  }

  loadFromSql(final MyDatabase db, [final String? query]) {
    final List<Json> result = db.select(query ?? sqlQuery());
    loadFromJson(result);
  }

  loadFromJson(final List<Json> rows) {
    clear();
    for (final Json row in rows) {
      final T? newInstance = instanceFromSqlite(row);
      if (newInstance != null) {
        addEntry(newInstance);
      }
    }
  }

  loadDemoData() {
    clear();
  }

  /// Must be override by derived class
  T? instanceFromSqlite(final Json row) {
    return null;
  }

  /// Override in derived classes
  void onAllDataLoaded() {
    // implement in the override derived classes
  }

  String toCSV() {
    return getCsvFromList(getListSortedById());
  }

  String getCsvHeader(final List<Object> declarations) {
    final List<String> headerList = <String>[];

    for (final dynamic field in declarations) {
      if (field.serializeName != '') {
        headerList.add('"${field.serializeName}"');
      }
    }
    return headerList.join(',');
  }

  String getCsvFromList(final List<T> sortedList) {
    final StringBuffer csv = StringBuffer();

    final List<Object> declarations = getFieldsForClass<T>();

    // CSV Header
    csv.writeln(getCsvHeader(declarations));

    // CSV Rows values
    for (final T item in sortedList) {
      final List<String> listValues = <String>[];

      for (final dynamic field in declarations) {
        if (field.serializeName != '') {
          listValues.add('"${field.valueForSerialization(item)}"');
        }
      }
      csv.writeln(listValues.join(','));
    }

    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    return '\uFEFF$csv';
  }
}
