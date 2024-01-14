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

  List<T> getAsList() {
    return _list;
  }

  void clear() {
    _list.clear();
  }

  int get length {
    return _list.length;
  }

  void addEntry(final MoneyObject entry) {
    _list.add(entry as T);
    _map[entry.id] = entry as T;
  }

  T? get(final num id) {
    return _map[id];
  }
}
