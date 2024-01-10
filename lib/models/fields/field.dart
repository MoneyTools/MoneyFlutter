import 'package:flutter/widgets.dart';
import 'package:money/helpers/string_helper.dart';

enum FieldType {
  text,
  numeric,
  numericShorthand,
  amount,
  amountShorthand,
  date,
}

class FieldDefinition<T> {
  final String name;
  String? serializeName;
  final FieldType type;
  final TextAlign align;
  final int Function(T, T, bool) sort;
  final bool readOnly;
  final bool isMultiLine;
  dynamic Function(int)? valueFromList;
  dynamic Function(T)? valueFromInstance;

  FieldDefinition({
    required this.name,
    this.serializeName,
    required this.type,
    required this.align,
    this.valueFromList,
    this.valueFromInstance,
    required this.sort,
    this.readOnly = true,
    this.isMultiLine = false,
  });

  Widget getWidget(final dynamic value) {
    switch (type) {
      case FieldType.numeric:
        return buildFieldWidgetForNumber(value as num, false);
      case FieldType.numericShorthand:
        return buildFieldWidgetForNumber(value as num, true);
      case FieldType.amount:
        return buildFieldWidgetForCurrency(value, false);
      case FieldType.amountShorthand:
        return buildFieldWidgetForCurrency(value, true);
      case FieldType.text:
      default:
        return buildFieldWidgetForText(value as String, textAlign: align);
    }
  }

  String getString(final dynamic value) {
    switch (type) {
      case FieldType.numeric:
        return (value as num).toString();
      case FieldType.numericShorthand:
        return getNumberAsShorthandText(value as num);
      case FieldType.amount:
        return getCurrencyText(value as double);
      case FieldType.amountShorthand:
        return getNumberAsShorthandText(value as double);
      case FieldType.text:
      default:
        return value as String;
    }
  }
}

Widget buildFieldWidgetForText(
  final String text, {
  final TextAlign textAlign = TextAlign.left,
}) {
  return Expanded(
      child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: textAlign == TextAlign.left ? Alignment.centerLeft : Alignment.center,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
            child: Text(text, textAlign: textAlign),
          )));
}

Widget buildFieldWidgetForCurrency(
  final dynamic value,
  final bool shorthand,
) {
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

Widget buildFieldWidgetForNumber(
  final num value,
  final bool shorthand,
) {
  return Expanded(
      child: FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerRight,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: Text(
        shorthand ? getNumberAsShorthandText(value) : getNumberText(value),
        textAlign: TextAlign.right,
      ),
    ),
  ));
}
