import 'package:money/models/fields/fields.dart';
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
        (a as MoneyObject).id,
        (b as MoneyObject).id,
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
    _map[(entry as MoneyObject).id] = entry;
  }

  T? get(final num id) {
    return _map[id];
  }

  String toCSV() {
    return getCsvFromList(
      MoneyObject.getFieldDefinitions<T>(),
      getListSortedById(),
    );
  }

  String getCsvFromList(final FieldDefinitions<T> fieldDefinitions, final List<T> sortedList) {
    final StringBuffer csv = StringBuffer();

    // CSV Header
    csv.writeln(fieldDefinitions.getCsvHeader());

    // CSV Rows
    for (final T item in sortedList) {
      csv.writeln(fieldDefinitions.getCsvRowValues(item));
    }

    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    return '\uFEFF$csv';
  }
}
