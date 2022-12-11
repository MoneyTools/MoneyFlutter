import 'dart:ui';

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
