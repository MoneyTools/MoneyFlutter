// Imports
import 'package:flutter/material.dart';
import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/fields/field_filter.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/payees/payee.dart';

// Exports
export 'package:money/models/fields/field.dart';

/// Manages a collection of field definitions for a specific data type.
///
/// The `Fields<T>` class provides a way to define and manage a set of fields
/// associated with a specific data type `T`. It allows you to:
///
/// - Define field definitions, including their name, type, and other properties.
/// - Retrieve the field definitions that should be used as columns.
/// - Check if the field definitions are empty.
/// - Apply filters to a `MoneyObject` instance based on free-style text search
///   and column-based filtering.
/// - Get a list of field values as strings for a given `MoneyObject` instance.
/// - Generate a row of columns for a table view based on the field definitions.
/// - Set the field definitions for the class.
///
/// The `Fields<T>` class is designed to be used in the context of the
/// `MoneyTools/MoneyFlutter` project, where it plays a crucial role in
/// managing the fields and filtering functionality for the application.
///
/// @param <T> The data type associated with the field definitions.
class Fields<T> {
  final FieldDefinitions definitions = [];

  /// Constructor
  Fields() {
    assert(T != dynamic, 'Type T cannot be dynamic');
  }

  Iterable<Field> get fieldDefinitionsForColumns {
    return definitions.where((element) => element.useAsColumn == true);
  }

  bool get isEmpty {
    return definitions.isEmpty;
  }

  bool applyFilters(
    final MoneyObject objectInstance,
    final String filterBytFreeStyleLowerCaseText, // Optional empty string
    final FieldFilters filterByFieldsValue, // Optional empty array
  ) {
    // Optimize - Simple case of using partial text search in all fields, no Column field fitering
    if (filterByFieldsValue.isEmpty) {
      // If no field filters are provided, check if the lowerCaseTextToFind matches
      return isMatchingFreeStyleText(objectInstance, filterBytFreeStyleLowerCaseText);
    }

    // Optimize - Looking for column matching
    if (filterBytFreeStyleLowerCaseText.isEmpty) {
      return isMatchingColumnFiltering(objectInstance, filterByFieldsValue);
    }

    // Looking for Both freestyle text and column fitlering, both condition needs to be met
    bool wasFoundFreeStyleTextSearch = false;
    bool wasFoundColumnFilters = false;

    for (final fieldDefinition in fieldDefinitionsForColumns) {
      String fieldValueAsString = _getFieldValueAsStringForFiltering(
        objectInstance,
        fieldDefinition,
      );

      if (wasFoundColumnFilters == false) {
        // continue to search for a column match
        if (isFieldMatching(fieldDefinition, fieldValueAsString, filterByFieldsValue)) {
          wasFoundColumnFilters = true;
        }
      }

      // check to see if at least one field contains the free style filter text
      if (wasFoundFreeStyleTextSearch == false) {
        if (fieldValueAsString.contains(filterBytFreeStyleLowerCaseText)) {
          wasFoundFreeStyleTextSearch = true;
        }
      }
    }

    // both filter mode are requested, thus we need both to have been matched
    return wasFoundFreeStyleTextSearch && wasFoundColumnFilters;
  }

  // check if the lowerCaseTextToFind matches any of the fields text value
  bool isMatchingFreeStyleText(MoneyObject objectInstance, String filterBytFreeStyleLowerCaseText) {
    for (final fieldDefinition in fieldDefinitionsForColumns) {
      final fieldValueAsString = _getFieldValueAsStringForFiltering(
        objectInstance,
        fieldDefinition,
      );

      if (fieldValueAsString.contains(filterBytFreeStyleLowerCaseText)) {
        return true;
      }
    }
    return false;
  }

  bool isMatchingColumnFiltering(
    final MoneyObject objectInstance,
    final FieldFilters filterByFieldsValue,
  ) {
    for (final Field fieldDefinition in fieldDefinitionsForColumns) {
      String fieldValueAsString = _getFieldValueAsStringForFiltering(
        objectInstance,
        fieldDefinition,
      );

      if (isFieldMatching(fieldDefinition, fieldValueAsString, filterByFieldsValue)) {
        return true;
      }
    }
    return false;
  }

  /// Checks if a given field definition matches the provided filters.
  ///
  /// This function is used to determine whether a field definition matches the
  /// specified filters in the filtering process.
  ///
  /// @param fieldDefinition The [Field] definition to be checked.
  /// @param fieldValueAsStringInLowerCase The field value as a lowercase string.
  /// @param filterByFieldsValue The list of [FieldFilter] objects containing the
  ///        field name and the filter text.
  /// @return `true` if the field definition matches the filters, `false` otherwise.
  bool isFieldMatching(
    Field<dynamic> fieldDefinition,
    String fieldValueAsStringInLowerCase,
    FieldFilters filterByFieldsValue,
  ) {
    for (final FieldFilter filter in filterByFieldsValue.list) {
      if (fieldDefinition.name == filter.fieldName) {
        if (fieldValueAsStringInLowerCase == filter.filterTextInLowerCase) {
          return true;
        }
      }
    }
    return false;
  }

  /// Converts the given field value to a string representation suitable for filtering.
  ///
  /// For date fields, the value is converted to a string in the format "YYYY-MM-DD" without the time component.
  /// For all other field types, the value is converted to a lowercase string using the generic `toString()` method.
  ///
  /// This function is used to prepare field values for comparison during the filtering process.
  ///
  /// @param fieldDefinition The [Field] definition for the current field.
  /// @param fieldValue The value of the current field.
  /// @return The string representation of the field value, suitable for filtering.
  String _getFieldValueAsStringForFiltering(
    final MoneyObject objectInstance,
    Field<dynamic> fieldDefinition,
  ) {
    final dynamic fieldValue = fieldDefinition.type == FieldType.widget
        ? fieldDefinition.getValueForSerialization(objectInstance)
        : fieldDefinition.getValueForDisplay(objectInstance);

    switch (fieldDefinition.type) {
      case FieldType.date:
        return dateToString(fieldValue);
      case FieldType.quantity:
        return formatDoubleTrimZeros(fieldValue);
      default:
        return fieldValue.toString().toLowerCase();
    }
  }

  String getCsvRowValues(final MoneyObject item) {
    final List<dynamic> listOfValues = <dynamic>[];
    for (final Field<dynamic> field in definitions) {
      listOfValues.add('"${field.getValueForSerialization(item)}"');
    }
    return listOfValues.join(',');
  }

  Field getFieldByName(final String name) {
    return definitions.firstWhere((field) => field.name == name);
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
        final dynamic rawValue = fieldDefinition.getValueForDisplay(objectInstance);
        strings.add(fieldDefinition.getString(rawValue));
      }
    }
    return strings;
  }

  /// Used in table view
  Widget getRowOfColumns(final MoneyObject objectInstance) {
    final List<Widget> cells = <Widget>[];

    for (final Field fieldDefinition in definitions) {
      final dynamic value = fieldDefinition.getValueForDisplay(objectInstance);
      cells.add(
        Expanded(
          flex: fieldDefinition.columnWidth.index,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
            child: buildWidgetFromTypeAndValue(
              value: value,
              type: fieldDefinition.type,
              align: fieldDefinition.align,
              fixedFont: fieldDefinition.fixedFont,
            ),
          ),
        ),
      );
    }

    return Row(children: cells);
  }

  void setDefinitions(List<Field<dynamic>> list) {
    definitions.clear();
    for (var object in list) {
      definitions.add(object);
    }
  }
}
