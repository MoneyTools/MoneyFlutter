import 'package:flutter/material.dart';

import 'package:money/widgets/fields/field.dart';

class FieldDefinitions<T> {
  final List<FieldDefinition<T>> list;

  FieldDefinitions({required this.list}) {
    assert(T != dynamic, 'Type T cannot be dynamic');
  }

  List<Widget> getRowOfColumns(final int index) {
    final List<Widget> cells = <Widget>[];
    for (int columnIndex = 0; columnIndex < list.length; columnIndex++) {
      final Widget widget = getWidgetForField(columnIndex, index);
      cells.add(widget);
    }
    return cells;
  }

  Widget getWidgetForField(final int columnIndex, final int index) {
    final FieldDefinition<T> fieldDefinition = list[columnIndex];
    final dynamic fieldValue = list[columnIndex].value(index);
    return fieldDefinition.getWidget(fieldValue);
  }

  FieldDefinitions<T> add(final FieldDefinition<T> toAdd) {
    list.add(toAdd);
    return this;
  }

  FieldDefinitions<T> removeAt(final int index) {
    list.removeAt(index);
    return this;
  }

  List<Widget> getCellsForDetailsPanel(final int index) {
    final List<Widget> cells = <Widget>[];
    for (int i = 0; i < list.length; i++) {
      final Widget widget = getBestWidgetForFieldDefinition(i, index);
      cells.add(widget);
    }
    return cells;
  }

  List<String> getFieldValuesAstString(final int rowIndex) {
    final List<String> strings = <String>[];
    for (int fieldIndex = 0; fieldIndex < list.length; fieldIndex++) {
      final FieldDefinition<T> fieldDefinition = list[fieldIndex];
      strings.add(fieldDefinition.getString(fieldDefinition.value(rowIndex)));
    }
    return strings;
  }

  Widget getBestWidgetForFieldDefinition(final int columnIndex, final int rowIndex) {
    final FieldDefinition<T> fieldDefinition = list[columnIndex];
    final dynamic fieldValue = fieldDefinition.value(rowIndex);

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
}
