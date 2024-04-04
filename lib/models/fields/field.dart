import 'package:flutter/material.dart';
import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_object.dart';

typedef FieldDefinitions = List<Field<dynamic>>;

class Field<T> {
  late T value;
  String name;
  String serializeName;
  FieldType type;
  String currency; // used for FieldType.amount
  ColumnWidth columnWidth;
  TextAlign align;
  bool useAsColumn;
  bool useAsDetailPanels;
  bool isMultiLine = false;
  int importance;

  /// Get the value of the instance
  dynamic Function(MoneyObject) valueFromInstance;

  /// Customize/override the edit widget
  Widget Function(MoneyObject, Function onEdited)? getEditWidget;

  /// override the value edited
  dynamic Function(MoneyObject, dynamic)? setValue;

  /// Get the value for storing the instance
  dynamic Function(MoneyObject) valueForSerialization;
  int Function(MoneyObject, MoneyObject, bool)? sort;

  // void operator = (final T newValue) {
  //   _value = newValue;
  // };

  Field({
    this.type = FieldType.text,
    this.currency = Constants.defaultCurrency,
    this.align = TextAlign.left,
    this.isMultiLine = false,
    this.columnWidth = ColumnWidth.normal,
    this.name = '',
    this.serializeName = '',
    required final T defaultValue,
    this.importance = -1,
    this.valueFromInstance = defaultCallbackValue,
    this.getEditWidget,
    this.setValue,
    this.valueForSerialization = defaultCallbackValue,
    this.useAsColumn = true,
    this.useAsDetailPanels = true,
    this.sort,
  }) {
    value = defaultValue;
    if (name.isEmpty) {
      name = serializeName;
    }

    if (valueFromInstance == defaultCallbackValue) {
      switch (this.type) {
        case FieldType.numeric:
          valueFromInstance = (final MoneyObject c) => value as num;
          valueForSerialization = valueFromInstance;
        case FieldType.text:
          valueFromInstance = (final MoneyObject objectInstance) => value.toString();
        case FieldType.amount:
          valueFromInstance =
              (final MoneyObject c) => Currency.getAmountAsStringUsingCurrency(value as double, iso4217code: currency);
        case FieldType.date:
          valueFromInstance = (final MoneyObject c) => dateToString(value as DateTime);
        default:
          //
          debugPrint('No match');
      }
    }
    if (valueForSerialization == defaultCallbackValue) {
      // if there's no override function
      // apply the same data value to serial
      valueForSerialization = valueFromInstance;
    }

    if (sort == null) {
      // if no override on sorting fallback to type sorting
      switch (type) {
        case FieldType.numeric:
        case FieldType.numericShorthand:
          sort = (final MoneyObject a, final MoneyObject b, final bool ascending) =>
              sortByValue(valueFromInstance(a) as num, valueFromInstance(b) as num, ascending);
        case FieldType.amount:
        case FieldType.amountShorthand:
          sort = (final MoneyObject a, final MoneyObject b, final bool ascending) =>
              sortByValue(valueFromInstance(a) as double, valueFromInstance(b) as double, ascending);
        case FieldType.date:
          sort = (final MoneyObject a, final MoneyObject b, final bool ascending) =>
              sortByDate(valueFromInstance(a), valueFromInstance(b), ascending);
        case FieldType.text:
        default:
          sort = (final MoneyObject a, final MoneyObject b, final bool ascending) =>
              sortByString(valueFromInstance(a).toString(), valueFromInstance(b).toString(), ascending);
      }
    }
  }

  String getBestFieldDescribingName() {
    if (serializeName.isNotEmpty) {
      return serializeName;
    }
    if (name.isNotEmpty) {
      return name;
    }
    return T.toString();
  }

  String getString(final dynamic value) {
    switch (type) {
      case FieldType.numeric:
        return value.toString();
      case FieldType.numericShorthand:
        return getAmountAsShorthandText(value as num);
      case FieldType.amount:
        return Currency.getAmountAsStringUsingCurrency(value);
      case FieldType.amountShorthand:
        return getAmountAsShorthandText(value as double);
      case FieldType.widget:
        return value;
      case FieldType.text:
      default:
        return value.toString();
    }
  }

  Widget getAsCompactWidget(final dynamic value, [double width = 300]) {
    if (type == FieldType.widget) {
      return value;
    } else {
      return SizedBox(
        width: width,
        child: SelectableText(
          getString(value),
          maxLines: 1,
          // overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }
  }
}

class FieldInt extends Field<int> {
  FieldInt({
    super.importance,
    super.name,
    super.serializeName,
    super.valueFromInstance,
    super.valueForSerialization,
    super.useAsColumn,
    super.useAsDetailPanels,
    super.getEditWidget,
    super.sort,
    super.columnWidth,
    super.align = TextAlign.right,
    super.type = FieldType.numeric,
  }) : super(
          defaultValue: -1,
        );
}

class FieldDouble extends Field<double> {
  FieldDouble({
    super.importance,
    super.name,
    super.serializeName,
    super.valueFromInstance,
    super.valueForSerialization,
    super.useAsColumn,
    super.useAsDetailPanels,
    super.sort,
  }) : super(
          defaultValue: 0.00,
          align: TextAlign.right,
          type: FieldType.numeric,
        );
}

class FieldAmount extends Field<double> {
  FieldAmount({
    super.importance,
    super.name,
    super.serializeName,
    super.valueFromInstance,
    super.valueForSerialization,
    super.setValue,
    super.useAsColumn,
    super.columnWidth = ColumnWidth.small,
    super.useAsDetailPanels,
    super.sort,
  }) : super(
          defaultValue: 0.00,
          currency: Constants.defaultCurrency,
          align: TextAlign.right,
          type: FieldType.amount,
        );
}

class FieldDate extends Field<DateTime?> {
  FieldDate({
    super.importance,
    super.name,
    super.serializeName,
    super.valueFromInstance,
    super.valueForSerialization,
    super.useAsColumn,
    super.useAsDetailPanels,
    super.sort,
    super.columnWidth = ColumnWidth.small,
    super.getEditWidget,
  }) : super(
          defaultValue: null,
          align: TextAlign.center,
          type: FieldType.date,
        );
}

class FieldString extends Field<String> {
  FieldString({
    super.importance,
    super.name,
    super.serializeName,
    super.valueFromInstance,
    super.valueForSerialization,
    super.useAsColumn = true,
    super.columnWidth,
    super.useAsDetailPanels = true,
    super.align = TextAlign.left,
    super.isMultiLine = false,
    super.getEditWidget,
    super.setValue,
    super.sort,
  }) : super(
          defaultValue: '',
          type: FieldType.text,
        ) {
    if (sort == null) {
      super.sort = (final MoneyObject a, final MoneyObject b, final bool ascending) {
        return sortByString(valueFromInstance(a), valueFromInstance(b), ascending);
      };
    }
  }
}

class DeclareNoSerialized<T> extends Field<T> {
  DeclareNoSerialized({
    required super.defaultValue,
    super.type,
    super.name,
    super.align,
    super.valueFromInstance,
    super.valueForSerialization,
  }) : super(serializeName: '');
}

class FieldId extends Field<int> {
  FieldId({
    super.importance = 0,
    super.valueFromInstance,
    super.valueForSerialization,
  }) : super(
          serializeName: 'Id',
          useAsColumn: false,
          useAsDetailPanels: false,
          defaultValue: -1,
        );
}

Widget buildFieldWidgetForText({
  final String text = '',
  final TextAlign align = TextAlign.left,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
    child: Text(
      text, textAlign: align,
      overflow: TextOverflow.ellipsis, // Clip with ellipsis
      maxLines: 1, // Restrict to single line,
    ),
  );
}

Widget buildFieldWidgetForCurrency({
  final dynamic value = 0,
  final String currency = Constants.defaultCurrency,
  final bool shorthand = false,
  final TextAlign align = TextAlign.right,
}) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    alignment: textAlignToAlignment(align),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: Text(
        shorthand
            ? getAmountAsShorthandText(value as num)
            : Currency.getAmountAsStringUsingCurrency(value, iso4217code: currency),
        textAlign: align,
      ),
    ),
  );
}

Widget buildFieldWidgetForNumber({
  final num value = 0,
  final bool shorthand = false,
  final TextAlign align = TextAlign.right,
}) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    alignment: textAlignToAlignment(align),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: Text(
        shorthand ? getAmountAsShorthandText(value) : getNumberShorthandText(value),
        textAlign: align,
      ),
    ),
  );
}

Alignment textAlignToAlignment(final TextAlign textAlign) {
  switch (textAlign) {
    case TextAlign.left:
      return Alignment.centerLeft;
    case TextAlign.center:
      return Alignment.center;
    case TextAlign.right:
    default:
      return Alignment.centerRight;
  }
}

enum FieldType {
  text,
  numeric,
  numericShorthand,
  amount,
  amountShorthand,
  date,
  toggle, // On/Off
  widget,
}

Widget buildWidgetFromTypeAndValue(
  final dynamic value,
  final FieldType type,
  final TextAlign align,
) {
  switch (type) {
    case FieldType.numeric:
      return buildFieldWidgetForNumber(value: value as num, shorthand: false, align: align);
    case FieldType.numericShorthand:
      return buildFieldWidgetForNumber(value: value as num, shorthand: true, align: align);
    case FieldType.amount:
      return buildFieldWidgetForCurrency(value: value, shorthand: false, align: align);
    case FieldType.amountShorthand:
      return buildFieldWidgetForCurrency(value: value, shorthand: true, align: align);
    case FieldType.widget:
      return Center(child: value as Widget);
    case FieldType.date:
      if (value == null) {
        return buildFieldWidgetForText(text: '____-__-__', align: align);
      }
      return buildFieldWidgetForText(text: value is DateTime ? dateToString(value) : value.toString(), align: align);
    case FieldType.text:
    default:
      return buildFieldWidgetForText(text: value.toString(), align: align);
  }
}

dynamic defaultCallbackValue(final dynamic instance) => '';

enum ColumnWidth {
  hide, // 0
  nano, // 1
  tiny, // 1
  small, // 2
  normal, // 3
  large, // 4
  largest, // 5
}
