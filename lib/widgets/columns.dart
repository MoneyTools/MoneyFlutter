import 'package:flutter/material.dart';

import '../helpers.dart';

enum ColumnType {
  text,
  numeric,
  amount,
  date,
}

class ColumnDefinition {
  String name = "";
  TextAlign align = TextAlign.center;
  Function? getFieldValue;
  Function? sorting;
  ColumnType type = ColumnType.text;

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
      var fieldValue = list[i].getFieldValue!(index);
      cells.add(
        TextFormField(
          initialValue: fieldValue.toString(),
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: list[i].name,
          ),
        ),
      );
    }
    return cells;
  }

  Widget getCellWidget(int columnId, Object value) {
    var columnDefinition = list[columnId];
    switch (columnDefinition.type) {
      case ColumnType.numeric:
        return renderColumValueEntryNumber(value);
      case ColumnType.amount:
        return renderColumValueEntryCurrency(value);
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

  Widget renderColumValueEntryCurrency(value) {
    return Expanded(
        child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
        child: Text(
          getCurrencyText(value),
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
