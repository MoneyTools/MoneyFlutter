// Imports
import 'package:flutter/material.dart';
import 'package:money/models/fields/field_filter.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/money_objects.dart';

// Exports
export 'package:money/models/fields/field.dart';

class Fields<T> {
  FieldDefinitions definitions;

  /// Constructor
  Fields({required this.definitions}) {
    assert(T != dynamic, 'Type T cannot be dynamic');
  }

  bool get isEmpty {
    return definitions.isEmpty;
  }

  void setDefinitions(List<Object> list) {
    definitions.clear();
    for (var object in list) {
      definitions.add(object as Field<dynamic>);
    }
  }

  Field getFieldByName(final String name) {
    return definitions.firstWhere((field) => field.name == name);
  }

  /// Used in table view
  Widget getRowOfColumns(final MoneyObject objectInstance) {
    final List<Widget> cells = <Widget>[];

    for (int columnIndex = 0; columnIndex < definitions.length; columnIndex++) {
      final Field<dynamic> fieldDefinition = definitions[columnIndex];
      final dynamic value = fieldDefinition.valueFromInstance(objectInstance);
      cells.add(
        Expanded(
          flex: fieldDefinition.columnWidth.index,
          child: buildWidgetFromTypeAndValue(
            value,
            fieldDefinition.type,
            fieldDefinition.align,
          ),
        ),
      );
    }

    return Row(children: cells);
  }

  FieldDefinitions getFieldsForClass<C>() {
    definitions.sort((final Field<dynamic> a, final Field<dynamic> b) {
      int result = 0;

      if (a.importance == -1 && b.importance >= 0) {
        return 1;
      }

      if (b.importance == -1 && a.importance >= 0) {
        return -1;
      }

      result = a.importance.compareTo(b.importance);

      if (result == 0) {
        // secondary sorting order is based on [serializeName]
        return a.serializeName.compareTo(b.serializeName);
      }
      return result;
    });

    return definitions;
  }

  List<String> getListOfFieldValueAsString(final MoneyObject objectInstance, [final bool includeHiddenFields = false]) {
    final List<String> strings = <String>[];
    for (int fieldIndex = 0; fieldIndex < definitions.length; fieldIndex++) {
      final Field<dynamic> fieldDefinition = definitions[fieldIndex];
      if (includeHiddenFields == true || fieldDefinition.useAsColumn == true) {
        final dynamic rawValue = fieldDefinition.valueFromInstance(objectInstance);
        strings.add(fieldDefinition.getString(rawValue));
      }
    }
    return strings;
  }

  bool applyFilters(
    final MoneyObject objectInstance,
    final String lowerCaseTextToFind,
    final List<FieldFilter> filterByFieldsValue,
  ) {
    bool atLeastOneFieldMatchText = false;

    for (int fieldIndex = 0; fieldIndex < definitions.length; fieldIndex++) {
      // Field Definition
      final Field<dynamic> fieldDefinition = definitions[fieldIndex];

      // Only Field that are being displayed
      if (fieldDefinition.useAsColumn == true) {
        // Value of this field
        final dynamic rawValue = fieldDefinition.valueFromInstance(objectInstance);

        // field specific filters
        if (!isMatchingFieldValues(
          fieldDefinition,
          rawValue,
          filterByFieldsValue,
        )) {
          return false;
        }

        // check to see if at least one field contains the free style filter text
        if (atLeastOneFieldMatchText == false) {
          if (lowerCaseTextToFind.isEmpty ||
              fieldDefinition.getString(rawValue).toLowerCase().contains(lowerCaseTextToFind)) {
            if (filterByFieldsValue.isEmpty) {
              // we can stop, we have one match and there's not field specific filters
              return true;
            }
            atLeastOneFieldMatchText = true;
          }
        }
      }
    }

    if (lowerCaseTextToFind.isEmpty) {
      // this instance is valid
      return true;
    }
    return atLeastOneFieldMatchText;
  }

  bool isMatchingFieldValues(
    final Field<dynamic> fieldDefinition,
    dynamic rawValue,
    List<FieldFilter> filterByFieldsValue,
  ) {
    for (final filter in filterByFieldsValue) {
      if (!isMatchingFieldValue(fieldDefinition, rawValue, filter)) {
        return false;
      }
    }
    return true;
  }

  bool isMatchingFieldValue(
    final Field<dynamic> fieldDefinition,
    dynamic rawValue,
    FieldFilter filter,
  ) {
    if (fieldDefinition.name == filter.fieldName) {
      return rawValue.toString().toLowerCase() == filter.filterTextInLowerCase;
    }
    return true;
  }

  String getCsvRowValues(final MoneyObject item) {
    final List<dynamic> listOfValues = <dynamic>[];
    for (final Field<dynamic> field in definitions) {
      listOfValues.add('"${field.valueForSerialization(item)}"');
    }
    return listOfValues.join(',');
  }
}
