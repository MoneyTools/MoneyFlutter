import 'package:flutter/material.dart';

import 'package:money/helpers/string_helper.dart';

enum ColumnType {
  text,
  numeric,
  amount,
  amountShorthand,
  date,
}

class ColumnDefinition<T> {
  final String name;
  final ColumnType type;
  final TextAlign align;
  final dynamic Function(int) value;
  final int Function(T, T, bool) sort;
  final bool readOnly;
  final bool isMultiLine;

  ColumnDefinition({
    required this.name,
    required this.type,
    required this.align,
    required this.value,
    required this.sort,
    this.readOnly = true,
    this.isMultiLine = false,
  });
}

class ColumnDefinitions<T> {
  final List<ColumnDefinition<T>> list;

  ColumnDefinitions({required this.list}) {
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

  ColumnDefinitions<T> add(final ColumnDefinition<T> toAdd) {
    list.add(toAdd);
    return this;
  }

  ColumnDefinitions<T> removeAt(final int index) {
    list.removeAt(index);
    return this;
  }

  List<Widget> getCellsForDetailsPanel(final int index) {
    final List<Widget> cells = <Widget>[];
    for (int i = 0; i < list.length; i++) {
      final Widget widget = getBestWidgetForColumnDefinition(i, index);
      cells.add(widget);
    }
    return cells;
  }

  Widget getBestWidgetForColumnDefinition(final int columnIndex, final int rowIndex) {
    final ColumnDefinition<T> fieldDefinition = list[columnIndex];
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
    final ColumnDefinition<T> columnDefinition = list[columnId];
    switch (columnDefinition.type) {
      case ColumnType.numeric:
        return renderColumValueEntryNumber(value as num);
      case ColumnType.amount:
        return renderColumValueEntryCurrency(value, false);
      case ColumnType.amountShorthand:
        return renderColumValueEntryCurrency(value, true);
      case ColumnType.text:
      default:
        return renderColumValueEntryText(value as String, textAlign: columnDefinition.align);
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
