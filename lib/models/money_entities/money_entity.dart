import 'dart:ui';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/fields/field.dart';

class MoneyEntity {
  int id;
  String name;

  MoneyEntity({required this.id, required this.name}) {
    //
  }

  static String fromRowColumnToString(final Map<String, Object?> row, final String nameOfColumn) {
    final Object? rawValue = row[nameOfColumn];
    if (rawValue == null) {
      return '';
    }
    return rawValue.toString();
  }

  static int fromRowColumnToNumber(final Map<String, Object?> row, final String nameOfColumn) {
    final Object? rawValue = row[nameOfColumn];
    if (rawValue == null) {
      return 0;
    }
    final String rawValueAsText = rawValue.toString();
    return int.parse(rawValueAsText);
  }

  static double fromRowColumnToDouble(final Map<String, Object?> row, final String nameOfColumn) {
    final Object? rawValue = row[nameOfColumn];
    if (rawValue == null) {
      return 0.00;
    }
    final String rawValueAsText = rawValue.toString();
    return double.parse(rawValueAsText);
  }

  static DateTime? fromRowColumnToDateTime(final Map<String, Object?> row, final String nameOfColumn) {
    final String rawValue = fromRowColumnToString(row, nameOfColumn);
    if (rawValue.isEmpty) {
      return null;
    }
    return DateTime.parse(rawValue);
  }
}

class MoneyObjects<T> {
  final List<T> _list = <T>[];
  final Map<num, T> _map = <num, T>{};

  MoneyObjects() {
    //
  }

  List<T> getAsList() {
    return _list;
  }

  void clear() {
    _list.clear();
  }

  int get length {
    return _list.length;
  }

  void addEntry(final MoneyEntity entry) {
    _list.add(entry as T);
    _map[entry.id] = entry as T;
  }

  T? get(final num id) {
    return _map[id];
  }

  T? getByName(final String name) {
    for (final T item in _list) {
      if ((item as MoneyEntity).name == name) {
        return item;
      }
    }
    return null;
  }

  String getNameFromId(final num id) {
    final T? item = get(id);
    if (item == null) {
      return id.toString();
    }
    return (item as MoneyEntity).name;
  }

  FieldDefinition<T> getFieldId() {
    return FieldDefinition<T>(
      useAsColumn: false,
      name: 'Id',
      serializeName: 'id',
      type: FieldType.numeric,
      align: TextAlign.right,
      valueFromInstance: (final T entity) => (entity as MoneyEntity).id,
      sort: (final T a, final T b, final bool sortAscending) {
        return sortByValue((a as MoneyEntity).id, (b as MoneyEntity).id, sortAscending);
      },
    );
  }

  FieldDefinition<T> getFieldName({final bool useAsColumn = true}) {
    return FieldDefinition<T>(
      useAsColumn: useAsColumn,
      name: 'Name',
      serializeName: 'name',
      type: FieldType.text,
      align: TextAlign.left,
      valueFromInstance: (final T entity) => (entity as MoneyEntity).name,
      sort: (final T a, final T b, final bool sortAscending) {
        return sortByString((a as MoneyEntity).name, (b as MoneyEntity).name, sortAscending);
      },
    );
  }
}
