import 'dart:ui';

class ColumnDefinition {
  String name = "";
  TextAlign align = TextAlign.center;
  Function? sorting;

  ColumnDefinition(this.name, this.align, this.sorting) {
    //
  }
}
