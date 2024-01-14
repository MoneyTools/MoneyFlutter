import 'dart:ui';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/fields/field.dart';

class MoneyEntity {
  int id; // Mandatory

  MoneyEntity({required this.id}) {
    //
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
}
