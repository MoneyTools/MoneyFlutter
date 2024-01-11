import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:money/models/fields/field.dart';
export 'package:money/models/fields/field.dart';

class FieldDefinitions<T> {
  final List<FieldDefinition<T>> definitions;

  FieldDefinitions({required this.definitions}) {
    assert(T != dynamic, 'Type T cannot be dynamic');
  }

  FieldDefinition<T>? getFieldById(final String fieldName) {
    return definitions.firstWhereOrNull((final FieldDefinition<T> item) => item.name == fieldName);
  }

  List<Widget> getRowOfColumns(final int index) {
    final List<Widget> cells = <Widget>[];
    for (int columnIndex = 0; columnIndex < definitions.length; columnIndex++) {
      final Widget widget = getWidgetForField(columnIndex, index);
      cells.add(widget);
    }
    return cells;
  }

  Widget getWidgetForField(final int columnIndex, final int index) {
    final FieldDefinition<T> fieldDefinition = definitions[columnIndex];
    if (fieldDefinition.valueFromList == null) {
      return const SizedBox();
    }

    final dynamic fieldValue = fieldDefinition.valueFromList!(index);
    return fieldDefinition.getWidget(fieldValue);
  }

  FieldDefinitions<T> add(final FieldDefinition<T> toAdd) {
    definitions.add(toAdd);
    return this;
  }

  FieldDefinitions<T> removeAt(final int index) {
    definitions.removeAt(index);
    return this;
  }

  List<Widget> getCellsForDetailsPanel(final int index) {
    final List<Widget> cells = <Widget>[];
    for (int i = 0; i < definitions.length; i++) {
      final Widget widget = getBestWidgetForFieldDefinition(i, index);
      cells.add(widget);
    }
    return cells;
  }

  List<String> getFieldValuesAstString(final int rowIndex) {
    final List<String> strings = <String>[];
    for (int fieldIndex = 0; fieldIndex < definitions.length; fieldIndex++) {
      final FieldDefinition<T> fieldDefinition = definitions[fieldIndex];
      strings.add(fieldDefinition.getString(fieldDefinition.valueFromList!(rowIndex)));
    }
    return strings;
  }

  Widget getBestWidgetForFieldDefinition(final int columnIndex, final int rowIndex) {
    final FieldDefinition<T> fieldDefinition = definitions[columnIndex];
    if (fieldDefinition.valueFromList == null) {
      return const SizedBox();
    }

    final dynamic fieldValue = fieldDefinition.valueFromList!(rowIndex);

    if (fieldDefinition.isMultiLine) {
      return TextFormField(
        readOnly: fieldDefinition.readOnly,
        initialValue: fieldValue.toString(),
        keyboardType: TextInputType.multiline,
        minLines: 1,
        //Normal textInputField will be displayed
        maxLines: 5,
        // when user presses enter it will adapt to
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: fieldDefinition.name,
        ),
      );
    } else {
      return TextFormField(
        readOnly: fieldDefinition.readOnly,
        initialValue: fieldDefinition.getString(fieldValue),
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: fieldDefinition.name,
        ),
      );
    }
  }

  String getCsvHeader() {
    final List<String> headerList = <String>[];
    for (final FieldDefinition<T> field in definitions) {
      if (field.serializeName != null) {
        headerList.add('"${field.serializeName!}"');
      }
    }
    return headerList.join(',');
  }

  String getCsvRowValues(final T item) {
    final List<dynamic> listOfValues = <dynamic>[];
    for (final FieldDefinition<T> field in definitions) {
      if (field.serializeName != null && field.valueFromInstance != null) {
        listOfValues.add('"${field.valueFromInstance!(item)}"');
      }
    }
    return listOfValues.join(',');
  }
}
