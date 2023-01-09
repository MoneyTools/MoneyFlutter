import 'package:flutter/material.dart';

import '../helpers.dart';

enum ColumnType {
  text,
  numeric,
  amount,
  amountShorthand,
  date,
}

class ColumnDefinition {
  String name = "";
  TextAlign align = TextAlign.center;
  Function? getFieldValue;
  Function? sorting;
  ColumnType type = ColumnType.text;
  bool readOnly = true;
  bool isMultiLine = false;

  ColumnDefinition(this.name, this.type, this.align, this.getFieldValue, this.sorting) {
    //
  }
}

class ColumnDefinitions {
  List<ColumnDefinition> list = [];

  ColumnDefinitions(List<ColumnDefinition> initialList) {
    list = initialList;
  }

  getCellsForRow(index) {
    List<Widget> cells = [];
    for (int i = 0; i < list.length; i++) {
      var fieldValue = list[i].getFieldValue!(index);
      cells.add(getCellWidget(i, fieldValue));
    }
    return cells;
  }

  add(ColumnDefinition toAdd) {
    list.add(toAdd);
    return this;
  }

  getCellsForDetailsPanel(index) {
    List<Widget> cells = [];
    for (int i = 0; i < list.length; i++) {
      var widget = getBestWidgetForColumnDefinition(i, index);
      cells.add(widget);
    }
    return cells;
  }

  getBestWidgetForColumnDefinition(columnIndex, rowIndex) {
    var fieldDefinition = list[columnIndex];
    var fieldValue = fieldDefinition.getFieldValue!(rowIndex);

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

  Widget getCellWidget(int columnId, Object value) {
    var columnDefinition = list[columnId];
    switch (columnDefinition.type) {
      case ColumnType.numeric:
        return renderColumValueEntryNumber(value);
      case ColumnType.amount:
        return renderColumValueEntryCurrency(value, false);
      case ColumnType.amountShorthand:
        return renderColumValueEntryCurrency(value, true);
      case ColumnType.text:
      default:
        return renderColumValueEntryText(value, textAlign: columnDefinition.align);
    }
  }

  Widget renderColumValueEntryText(text, {TextAlign textAlign = TextAlign.left}) {
    return Expanded(
        child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: textAlign == TextAlign.left ? Alignment.centerLeft : Alignment.center,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
              child: Text(text, textAlign: textAlign),
            )));
  }

  Widget renderColumValueEntryCurrency(value, shorthand) {
    return Expanded(
        child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
        child: Text(
          shorthand ? getNumberAsShorthandText(value) : getCurrencyText(value),
          textAlign: TextAlign.right,
        ),
      ),
    ));
  }

  Widget renderColumValueEntryNumber(value) {
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
