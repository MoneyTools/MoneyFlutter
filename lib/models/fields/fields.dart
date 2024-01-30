import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/fields/field.dart';
import 'package:money/widgets/details_panel/details_panel_form_color.dart';
import 'package:money/widgets/details_panel/details_panel_form_widget.dart';
export 'package:money/models/fields/field.dart';

class Fields<T> {
  final List<Field<T, dynamic>> definitions;

  Fields({required this.definitions}) {
    assert(T != dynamic, 'Type T cannot be dynamic');
  }

  Widget getRowOfColumns(final T objectInstance) {
    final List<Widget> cells = <Widget>[];

    for (int columnIndex = 0; columnIndex < definitions.length; columnIndex++) {
      final Field<T, dynamic> fieldDefinition = definitions[columnIndex];
      if (fieldDefinition.useAsColumn) {
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
    }

    return Row(children: cells);
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
      final Field<T, dynamic> fieldDefinition = definitions[fieldIndex];
      if (includeHiddenFields == true || fieldDefinition.useAsColumn == true) {
        final dynamic rawValue = fieldDefinition.valueFromInstance(objectInstance);
        strings.add(fieldDefinition.getString(rawValue));
      }
    }
    return strings;
  }

  bool columnValueContainString(final T objectInstance, final String lowerCaseTextToFind) {
    for (int fieldIndex = 0; fieldIndex < definitions.length; fieldIndex++) {
      final Field<T, dynamic> fieldDefinition = definitions[fieldIndex];
      if (fieldDefinition.useAsColumn == true) {
        final dynamic rawValue = fieldDefinition.valueFromInstance(objectInstance);
        if (fieldDefinition.getString(rawValue).toLowerCase().contains(lowerCaseTextToFind)) {
          return true;
        }
      }
    }
    return false;
  }

  Widget getBestWidgetForFieldDefinition(final int columnIndex, final T objectInstance) {
    final Field<T, dynamic> fieldDefinition = definitions[columnIndex];

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
      if (fieldDefinition.type == FieldType.widget) {
        final String valueAsString = fieldDefinition.valueForSerialization(objectInstance).toString();
        if (fieldDefinition.name == 'Color') {
          return MyFormFieldForColor(
            title: fieldDefinition.name,
            color: getColorFromString(valueAsString),
          );
        } else {
          return MyFormFieldForWidget(
            title: fieldDefinition.name,
            valueAsText: valueAsString,
            child: fieldDefinition.valueFromInstance(objectInstance),
          );
        }
      }

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
    for (final Field<T, dynamic> field in definitions) {
      listOfValues.add('"${field.valueForSerialization(item)}"');
    }
    return listOfValues.join(',');
  }
}
