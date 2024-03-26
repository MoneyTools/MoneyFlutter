// Imports
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/database/database.dart';
import 'package:money/widgets/diff.dart';

// Exports
export 'package:collection/collection.dart';
export 'package:money/models/fields/fields.dart';
export 'package:money/models/money_objects/money_object.dart';

/// Collection of MoneyObject as both List and Map
class MoneyObjects<T> {
  /// Constructor
  MoneyObjects();

  String collectionName = '';

  final List<MoneyObject> _list = <MoneyObject>[];
  final Map<num, MoneyObject> _map = <num, MoneyObject>{};

  void clear() {
    _list.clear();
  }

  bool get isEmpty {
    return _list.isEmpty;
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
    return _iterableListOfMoneyObject(includeDeleted).whereType<T>();
  }

  T? firstItem([bool includeDeleted = false]) {
    final list = iterableList(includeDeleted).toList();
    if (list.isEmpty) {
      return null;
    }
    return iterableList(includeDeleted).toList().first;
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

  void appendMoneyObject(final MoneyObject moneyObject) {
    assert(moneyObject.uniqueId != -1);

    _list.add(moneyObject);
    _map[(moneyObject).uniqueId] = moneyObject;
  }

  int getNextId() {
    int nextId = -1;
    for (var moneyObject in _list) {
      nextId = max(nextId, moneyObject.uniqueId);
    }
    return nextId + 1;
  }

  void appendNewMoneyObject(final MoneyObject moneyObject) {
    assert(moneyObject.uniqueId == -1);

    // assign the next available unique ID
    moneyObject.uniqueId = getNextId();

    appendMoneyObject(moneyObject);

    Data().notifyTransactionChange(
      mutation: MutationType.inserted,
      moneyObject: moneyObject,
      fireNotification: true,
    );
  }

  T? get(final num id) {
    return _map[id] as T?;
  }

  void loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      final MoneyObject? newInstance = instanceFromSqlite(row);
      if (newInstance != null) {
        appendMoneyObject(newInstance);
      }
    }
  }

  void loadDemoData() {
    clear();
  }

  void assessMutationsCounts() {
    Settings().trackMutations.reset();
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

  List<MoneyObject> getMutatedObjects(MutationType typeOfMutation) {
    return _list.where((element) => element.mutation == typeOfMutation).toList();
  }

  bool saveSql(final MyDatabase db, final String tableName) {
    for (final item in _iterableListOfMoneyObject(true)) {
      switch (item.mutation) {
        case MutationType.none:
          break;
        case MutationType.inserted:
          db.insert(tableName, item.getPersistableJSon<T>());

        case MutationType.changed:
          db.update(tableName, item.uniqueId, item.getPersistableJSon<T>());

        case MutationType.deleted:
          db.delete(tableName, item.uniqueId);

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

  List<String> getSerializableFieldNames(final List<Object> declarations) {
    final List<String> fieldNames = <String>[];

    for (final dynamic field in declarations) {
      if (field.serializeName != '') {
        fieldNames.add(field.serializeName);
      }
    }
    return fieldNames;
  }

  String getCsvFromList(final List<MoneyObject> moneyObjects, [final String valueSeparator = ',']) {
    final StringBuffer csv = StringBuffer();

    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    csv.write('\uFEFF');

    final List<Object> declarations = getFieldsForClass<T>();

    // CSV Header
    csv.writeln(getCsvHeader(declarations));

    // CSV Rows values
    for (final MoneyObject item in moneyObjects) {
      csv.writeln(toStringAsSeparatedValues(declarations, item, valueSeparator));
    }

    return csv.toString();
  }

  List<String> getFieldNames() {
    final List<Object> declarations = getFieldsForClass<T>();
    return getSerializableFieldNames(declarations);
  }

  List<List<String>> getListOfValueList(List<MoneyObject> moneyObjects) {
    final List<Object> declarations = getFieldsForClass<T>();

    List<List<String>> list = [];
    for (final MoneyObject item in moneyObjects) {
      list.add(getListOfValueAsStrings(declarations, item));
    }
    return list;
  }

  String toStringAsSeparatedValues(
    List<Object> declarations,
    MoneyObject item, [
    final String valueSeparator = ',',
  ]) {
    final List<String> listValues = <String>[];
    for (final dynamic field in declarations) {
      if (field.serializeName != '') {
        final dynamic value = field.valueForSerialization(item);
        final String valueAsString = '"$value"';
        listValues.add(valueAsString);
      }
    }
    return listValues.join(valueSeparator);
  }

  List<String> getListOfValueAsStrings(List<Object> declarations, MoneyObject item) {
    final List<String> listValues = <String>[];
    for (final dynamic field in declarations) {
      if (field.serializeName != '') {
        final dynamic value = field.valueForSerialization(item);
        listValues.add(value.toString());
      }
    }
    return listValues;
  }

  List<Widget> whatWasMutated(List<MoneyObject> objects) {
    List<Widget> widgets = [];
    for (final moneyObject in objects) {
      final MyJson jsonDelta = moneyObject.getMutatedDiff<T>();

      List<Widget> diffWidgets = [];
      jsonDelta.forEach((key, value) {
        Widget instanceName = Text(key);
        switch (moneyObject.mutation) {
          case MutationType.inserted:
            diffWidgets.add(instanceName);
            diffWidgets.add(diffTextNewValue(value['after'].toString()));
          case MutationType.deleted:
            diffWidgets.add(diffTextOldValue(value.toString()));
          case MutationType.changed:
          default:
            diffWidgets.add(instanceName);
            diffWidgets.add(diffTextOldValue(value['before'].toString()));
            diffWidgets.add(diffTextNewValue(value['after'].toString()));
        }
      });

      widgets.add(
        Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.withOpacity(0.5), // Border color
              width: 1.0, // Border width
            ),
            borderRadius: BorderRadius.circular(8.0), // Optional: border radius
          ),
          child: ListTile(
            dense: true,
            title: Text('"${moneyObject.getRepresentation()}"'),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: diffWidgets,
            ),
            trailing: kDebugMode ? Text(moneyObject.uniqueId.toString()) : null,
          ),
        ),
      );
    }
    return widgets;
  }

  bool mutationUpdateItem(final MoneyObject item) {
    Data().notifyTransactionChange(mutation: MutationType.changed, moneyObject: item);
    return true;
  }

  /// Remove/tag a Transaction instance from the list in memory
  bool deleteItem(final MoneyObject itemToDelete) {
    Data().notifyTransactionChange(mutation: MutationType.deleted, moneyObject: itemToDelete);
    return true;
  }
}
