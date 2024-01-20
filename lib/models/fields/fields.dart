import 'package:flutter/material.dart';
import 'package:money/models/fields/field.dart';
export 'package:money/models/fields/field.dart';

class FieldDefinitions<T> {
  final List<Declare<T, dynamic>> definitions;

  FieldDefinitions({required this.definitions}) {
    assert(T != dynamic, 'Type T cannot be dynamic');
  }

  List<Widget> getRowOfColumns(final T objectInstance) {
    final List<Widget> cells = <Widget>[];
    for (int columnIndex = 0; columnIndex < definitions.length; columnIndex++) {
      final Declare<dynamic, dynamic> fieldDefinition = definitions[columnIndex];
      if (fieldDefinition.useAsColumn) {
        final Widget widgetForThatField = fieldDefinition.getWidget(objectInstance);
        cells.add(widgetForThatField);
      }
    }
    return cells;
  }

  List<Widget> getCellsForDetailsPanel(final T objectInstance) {
    final List<Widget> cells = <Widget>[];
    for (int i = 0; i < definitions.length; i++) {
      final Widget widget = getBestWidgetForFieldDefinition(i, objectInstance);
      cells.add(widget);
    }
    return cells;
  }

  List<String> getListOfFieldValueAsString(final T objectInstance, [final bool includeHiddenFields = false]) {
    final List<String> strings = <String>[];
    for (int fieldIndex = 0; fieldIndex < definitions.length; fieldIndex++) {
      final Declare<dynamic, dynamic> fieldDefinition = definitions[fieldIndex];
      if (includeHiddenFields == true || fieldDefinition.useAsColumn == true) {
        strings.add(fieldDefinition.getString(fieldDefinition.valueFromInstance(objectInstance)));
      }
    }
    return strings;
  }

  Widget getBestWidgetForFieldDefinition(final int columnIndex, final T objectInstance) {
    final Declare<T, dynamic> fieldDefinition = definitions[columnIndex];

    final dynamic fieldValue = fieldDefinition.valueFromInstance(objectInstance);

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

  String getCsvRowValues(final T item) {
    final List<dynamic> listOfValues = <dynamic>[];
    for (final Declare<dynamic, dynamic> field in definitions) {
      listOfValues.add('"${field.valueForSerialization(item)}"');
    }
    return listOfValues.join(',');
  }
}
