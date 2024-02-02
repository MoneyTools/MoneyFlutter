import 'package:money/models/data_io/data.dart';
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

  List<T> getList([bool includeDeleted = false]) {
    if (includeDeleted) {
      // No filtering needed
      return _list;
    }
    return _list.where((final T item) => (item as MoneyObject<T>).change != ChangeType.deleted).toList();
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

  void addEntry(final T entry, {bool isNewEntry = false}) {
    _list.add(entry);
    _map[(entry as MoneyObject<T>).uniqueId] = entry;

    // keep track
    if (isNewEntry) {
      entry.change = ChangeType.inserted;
      Data().notifyTransactionChange(ChangeType.inserted, entry);
    }
  }

  T? get(final num id) {
    return _map[id];
  }

  void loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      final T? newInstance = instanceFromSqlite(row);
      if (newInstance != null) {
        addEntry(newInstance);
      }
    }
  }

  void loadDemoData() {
    clear();
  }

  bool saveSql(final MyDatabase db) {
    return false;
  }

  /// Must be override by derived class
  T? instanceFromSqlite(final MyJson row) {
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

    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    csv.write('\uFEFF');

    final List<Object> declarations = getFieldsForClass<T>();

    // CSV Header
    csv.writeln(getCsvHeader(declarations));

    // CSV Rows values
    for (final T item in sortedList) {
      final List<String> listValues = <String>[];

      for (final dynamic field in declarations) {
        if (field.serializeName != '') {
          final dynamic value = field.valueForSerialization(item);
          listValues.add('"$value"');
        }
      }
      csv.writeln(listValues.join(','));
    }

    return csv.toString();
  }
}
