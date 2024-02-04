import 'package:flutter/foundation.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/database/database.dart';
import 'package:money/models/money_objects/money_object.dart';

// exports
export 'package:money/models/money_objects/money_object.dart';
export 'package:money/models/fields/fields.dart';
export 'package:collection/collection.dart';

/// Collection of MoneyObject as both List and Map
class MoneyObjects<T> {
  /// Constructor
  MoneyObjects();

  final List<MoneyObject> _list = <MoneyObject>[];
  final Map<num, MoneyObject> _map = <num, MoneyObject>{};

  void clear() {
    _list.clear();
  }

  int get length {
    return _list.length;
  }

  Iterable<MoneyObject> _iterableListOfMoneyObject([bool includeDeleted = false]) {
    if (includeDeleted) {
      // No filtering needed
      return _list;
    }
    return _list.where((final item) => item.mutation != MutationType.deleted);
  }

  /// Recast list as type <T>
  Iterable<T> iterableList([bool includeDeleted = false]) {
    return _list.whereType<T>();
  }

  List<MoneyObject> getListSortedById() {
    _list.sort((final MoneyObject a, final MoneyObject b) {
      return sortByValue(
        (a).uniqueId,
        (b).uniqueId,
        true,
      );
    });
    return _list;
  }

  void addEntry(final MoneyObject entry, {bool isNewEntry = false}) {
    _list.add(entry);
    _map[(entry).uniqueId] = entry;

    // keep track of new items, they will need to be persisted later
    if (isNewEntry) {
      if (entry.uniqueId == -1) {
        entry.uniqueId = length + 1;
      }

      entry.mutation = MutationType.inserted;
      Data().notifyTransactionChange(MutationType.inserted, entry);
    }
  }

  T? get(final num id) {
    return _map[id] as T?;
  }

  void loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      final MoneyObject? newInstance = instanceFromSqlite(row);
      if (newInstance != null) {
        addEntry(newInstance);
      }
    }
  }

  void loadDemoData() {
    clear();
  }

  void assessMutationsCounts() {
    for (final item in _iterableListOfMoneyObject(true)) {
      switch (item.mutation) {
        case MutationType.inserted:
          Settings().trackMutations.added++;
        case MutationType.changed:
          Settings().trackMutations.changed++;
        case MutationType.deleted:
          Settings().trackMutations.deleted++;
        default:
          break;
      }
    }
  }

  bool saveSql(final MyDatabase db, final String tableName) {
    for (final item in _iterableListOfMoneyObject(true)) {
      switch (item.mutation) {
        case MutationType.none:
          break;
        case MutationType.inserted:
          db.insert(tableName, item.getPersistableJSon<T>());

        case MutationType.deleted:
          db.delete(tableName, item.uniqueId);

        case MutationType.changed:
          db.update(tableName, item.uniqueId, item.getPersistableJSon<T>());

        default:
          debugPrint('Unhandled change ${item.mutation}');
      }
      item.mutation = MutationType.none;
    }
    return true;
  }

  /// Must be override by derived class
  MoneyObject? instanceFromSqlite(final MyJson row) {
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

  String getCsvFromList(final List<MoneyObject> sortedList) {
    final StringBuffer csv = StringBuffer();

    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    csv.write('\uFEFF');

    final List<Object> declarations = getFieldsForClass<T>();

    // CSV Header
    csv.writeln(getCsvHeader(declarations));

    // CSV Rows values
    for (final MoneyObject item in sortedList) {
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

  /// Remove/tag a Transaction instance from the list in memory
  bool deleteItem(final MoneyObject itemToDelete) {
    itemToDelete.mutation = MutationType.deleted;
    Data().notifyTransactionChange(MutationType.deleted, itemToDelete);
    return true;
  }
}
