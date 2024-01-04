class MoneyEntity {
  int id = -1;
  String name = '';

  MoneyEntity(this.id, this.name) {
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
}
