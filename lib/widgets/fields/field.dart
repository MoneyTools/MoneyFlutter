import 'dart:ui';

enum FieldType {
  text,
  numeric,
  amount,
  amountShorthand,
  date,
}

class FieldDefinition<T> {
  final String name;
  final FieldType type;
  final TextAlign align;
  final dynamic Function(int) value;
  final int Function(T, T, bool) sort;
  final bool readOnly;
  final bool isMultiLine;

  FieldDefinition({
    required this.name,
    required this.type,
    required this.align,
    required this.value,
    required this.sort,
    this.readOnly = true,
    this.isMultiLine = false,
  });
}
