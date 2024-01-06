import 'package:flutter/material.dart';

import 'package:money/helpers/string_helper.dart';
import 'package:money/widgets/fields/field.dart';

class FieldDefinitions<T> {
  final List<FieldDefinition<T>> list;

  FieldDefinitions({required this.list}) {
    assert(T != dynamic, 'Type T cannot be dynamic');
  }

  List<Widget> getCellsForRow(final int index) {
    final List<Widget> cells = <Widget>[];
    for (int i = 0; i < list.length; i++) {
      final dynamic fieldValue = list[i].value(index);
      cells.add(getCellWidget(i, fieldValue));
    }
    return cells;
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
        initialValue: fieldValue.toString(),
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: fieldDefinition.name,
        ),
      );
    }
  }

  Widget getCellWidget(final int columnId, final dynamic value) {
    final FieldDefinition<T> fieldDefinition = list[columnId];
    switch (fieldDefinition.type) {
      case FieldType.numeric:
        return renderColumValueEntryNumber(value as num);
      case FieldType.amount:
        return renderColumValueEntryCurrency(value, false);
      case FieldType.amountShorthand:
        return renderColumValueEntryCurrency(value, true);
      case FieldType.text:
      default:
        return renderColumValueEntryText(value as String, textAlign: fieldDefinition.align);
    }
  }

  Widget renderColumValueEntryText(final String text, {final TextAlign textAlign = TextAlign.left}) {
    return Expanded(
        child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: textAlign == TextAlign.left ? Alignment.centerLeft : Alignment.center,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
              child: Text(text, textAlign: textAlign),
            )));
  }

  Widget renderColumValueEntryCurrency(final dynamic value, final bool shorthand) {
    return Expanded(
        child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
        child: Text(
          shorthand ? getNumberAsShorthandText(value as num) : getCurrencyText(value as double),
          textAlign: TextAlign.right,
        ),
      ),
    ));
  }

  Widget renderColumValueEntryNumber(final num value) {
    return Expanded(
        child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
        child: Text(
          getNumberAsShorthandText(value),
          textAlign: TextAlign.right,
        ),
      ),
    ));
  }
}
