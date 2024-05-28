// Imports
import 'dart:math';

import 'package:collection/collection.dart';
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

  String getTypeName() {
    Type t = T;
    return t.toString().split('.').last;
  }

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
  Iterable<T> iterableList({bool includeDeleted = false}) {
    return _iterableListOfMoneyObject(includeDeleted).whereType<T>();
  }

  T? firstItem([bool includeDeleted = false]) {
    final list = iterableList(includeDeleted: includeDeleted).toList();
    if (list.isEmpty) {
      return null;
    }
    return iterableList(includeDeleted: includeDeleted).toList().first;
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

  MoneyObject appendNewMoneyObject(final MoneyObject moneyObject, {bool fireNotification = true}) {
    assert(moneyObject.uniqueId == -1);

    // assign the next available unique ID
    moneyObject.uniqueId = getNextId();

    appendMoneyObject(moneyObject);

    Data().notifyMutationChanged(
      mutation: MutationType.inserted,
      moneyObject: moneyObject,
      fireNotification: fireNotification,
    );
    return moneyObject;
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

  /// Resets the mutation state of all MoneyObjects by setting their `valueBeforeEdit` to null
  /// and `mutation` to `MutationType.none`.
  ///
  void resetMutationStateOfObjects() {
    for (final item in _iterableListOfMoneyObject(true)) {
      item.valueBeforeEdit = null;
      item.mutation = MutationType.none;
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
          db.insert(tableName, item.getPersistableJSon());

        case MutationType.changed:
          db.update(tableName, item.uniqueId, item.getPersistableJSon());

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

  static String getCsvHeader(final FieldDefinitions declarations, final bool forSerialization) {
    final List<String> headerList = <String>[];

    for (final Field<dynamic> field in declarations) {
      if (isFieldMatchingCondition(field, forSerialization)) {
        headerList.add('"${field.getBestFieldDescribingName()}"');
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

  static String getCsvFromList(
    final List<MoneyObject> moneyObjects, {
    final String valueSeparator = ',',
    bool forSerialization = true,
  }) {
    final StringBuffer csv = StringBuffer();

    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    csv.write('\uFEFF');

    if (moneyObjects.isNotEmpty) {
      final FieldDefinitions declarations = moneyObjects.first.fieldDefinitions;

      // CSV Header
      csv.writeln(getCsvHeader(declarations, forSerialization));

      // CSV Rows values
      for (final MoneyObject item in moneyObjects) {
        csv.writeln(toStringAsSeparatedValues(declarations, item, valueSeparator, forSerialization));
      }
    }

    return csv.toString();
  }

  List<List<String>> getListOfValueList(List<MoneyObject> moneyObjects) {
    List<List<String>> list = [];
    if (moneyObjects.isNotEmpty) {
      final FieldDefinitions declarations = moneyObjects.first.fieldDefinitions;
      for (final MoneyObject item in moneyObjects) {
        list.add(getListOfValueAsStrings(declarations, item));
      }
    }
    return list;
  }

  static String toStringAsSeparatedValues(
    List<Object> declarations,
    MoneyObject item, [
    final String valueSeparator = ',',
    bool forSerialization = true,
  ]) {
    final List<String> listValues = <String>[];
    for (final dynamic field in declarations) {
      if (isFieldMatchingCondition(field, forSerialization)) {
        final dynamic value = forSerialization ? field.valueForSerialization(item) : field.getValueForDisplay(item);
        final String valueAsString = '"$value"';
        listValues.add(valueAsString);
      }
    }
    return listValues.join(valueSeparator);
  }

  static bool isFieldMatchingCondition(final field, bool forSerialization) {
    return ((forSerialization == true && field.serializeName.isNotEmpty) ||
        (forSerialization == false && field.useAsColumn));
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
        // Field Name
        Widget instanceName = Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(key),
        );
        switch (moneyObject.mutation) {
          case MutationType.inserted:
            diffWidgets.add(instanceName);
            diffWidgets.add(diffTextNewValue(value['after'].toString()));
          case MutationType.deleted:
            diffWidgets.add(instanceName);
            diffWidgets.add(diffTextOldValue(value['after'].toString()));
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

  void mutationUpdateItem(final MoneyObject item) {
    Data().notifyMutationChanged(mutation: MutationType.changed, moneyObject: item);
  }

  /// Remove/tag a Transaction instance from the list in memory
  void deleteItem(final MoneyObject itemToDelete) {
    Data().notifyMutationChanged(mutation: MutationType.deleted, moneyObject: itemToDelete);
  }

  MyJson getLastViewChoices() {
    return Settings().getLastViewChoices(getTypeName());
  }
}

MoneyObject? findObjectById(final int? uniqueId, final List<MoneyObject> listToSearch) {
  if (uniqueId == null) {
    return null;
  }
  return listToSearch.firstWhereOrNull((element) => (element).uniqueId == uniqueId);
}
