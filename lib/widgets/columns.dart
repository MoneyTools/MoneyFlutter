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
  Function? sorting;
  ColumnType type = ColumnType.text;

  ColumnDefinition(this.name, this.type, this.align, this.sorting) {
    //
  }
}
