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

  Iterable<Field> get fieldDefinitionsForColumns {
    return definitions.where((element) => element.useAsColumn == true);
  }

  /// Used in table view
  Widget getRowOfColumns(final MoneyObject objectInstance) {
    final List<Widget> cells = <Widget>[];

    for (final Field fieldDefinition in definitions) {
      final dynamic value = fieldDefinition.valueFromInstance(objectInstance);
      cells.add(
        Expanded(
          flex: fieldDefinition.columnWidth.index,
          child: buildWidgetFromTypeAndValue(
            value: value,
            type: fieldDefinition.type,
            align: fieldDefinition.align,
            fixedFont: fieldDefinition.fixedFont,
            // currency: fieldDefinition.currency,
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
    bool wasFoundFreeStyleTextSearch = false;
    bool wasFoundColumnFilters = false;

    for (final fieldDefinition in fieldDefinitionsForColumns) {
      // Value of this field
      final String fieldValue = fieldDefinition.valueFromInstance(objectInstance).toString().toLowerCase();

      if (filterByFieldsValue.isNotEmpty) {
        for (final FieldFilter filter in filterByFieldsValue) {
          if (fieldDefinition.name == filter.fieldName) {
            if (fieldValue == filter.filterTextInLowerCase) {
              // we have a specific field match
              if (lowerCaseTextToFind.isEmpty) {
                // speed up by short circuiting here
                return true;
              }
              wasFoundColumnFilters = true;
            }
          }
        }
      }

      // check to see if at least one field contains the free style filter text
      if (lowerCaseTextToFind.isNotEmpty && fieldValue.contains(lowerCaseTextToFind)) {
        if (filterByFieldsValue.isEmpty) {
          // speed up by short circuiting here
          return true;
        }
        wasFoundFreeStyleTextSearch = true;
      }
    }

    // both filter mode are requested, thus we need both to have been matched
    return wasFoundFreeStyleTextSearch && wasFoundColumnFilters;
  }

  String getCsvRowValues(final MoneyObject item) {
    final List<dynamic> listOfValues = <dynamic>[];
    for (final Field<dynamic> field in definitions) {
      listOfValues.add('"${field.valueForSerialization(item)}"');
    }
    return listOfValues.join(',');
  }
}
