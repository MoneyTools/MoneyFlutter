import 'package:flutter/material.dart';
import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/widgets/money_widget.dart';

export 'package:money/models/money_model.dart';

typedef FieldDefinitions = List<Field<dynamic>>;

class Field<T> {
  late T _value;

  // ignore: unnecessary_getters_setters
  T get value {
    return _value;
  }

  set value(T v) {
    _value = v;
  }

  String name;
  String serializeName;
  FieldType type;
  ColumnWidth columnWidth;
  TextAlign align;
  bool useAsColumn;
  bool useAsDetailPanels;
  bool fixedFont = false;
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
    this.align = TextAlign.left,
    this.isMultiLine = false,
    this.columnWidth = ColumnWidth.normal,
    this.fixedFont = false,
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
    ///----------------------------------------------
    /// default value for this field
    value = defaultValue;

    ///----------------------------------------------
    /// The name for this field
    if (name.isEmpty) {
      name = serializeName;
    }

    ///----------------------------------------------
    /// How to get the value of this field
    if (valueFromInstance == defaultCallbackValue) {
      switch (this.type) {
        case FieldType.numeric:
          valueFromInstance = (final MoneyObject c) => value as num;
          valueForSerialization = valueFromInstance;
        case FieldType.text:
          valueFromInstance = (final MoneyObject objectInstance) => value.toString();
        case FieldType.amount:
          valueFromInstance = (final MoneyObject c) => MoneyWidget(amountModel: value as MoneyModel);
        case FieldType.date:
          valueFromInstance = (final MoneyObject c) => dateToString(value as DateTime?);
        default:
          //
          debugPrint('No match');
      }
    }

    ///----------------------------------------------
    /// How to serialize this field
    if (valueForSerialization == defaultCallbackValue) {
      // if there's no override function
      // apply the same data value to serial
      valueForSerialization = valueFromInstance;
    }

    ///----------------------------------------------
    /// How to Sort on this field
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
              sortByValue(valueFromInstance(a).amount, valueFromInstance(b).amount, ascending);
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
        if (type is MoneyModel) {
          return (value as MoneyModel).toString();
        }
        if (value is double) {
          return Currency.getAmountAsStringUsingCurrency(value);
        }
        return value.toString();
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

class FieldMoney extends Field<MoneyModel> {
  FieldMoney({
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
          defaultValue: MoneyModel(amount: 0.00, autoColor: true),
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
          align: TextAlign.left,
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
    super.fixedFont = false,
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

Widget buildFieldWidgetForDate({
  final DateTime? date,
  final TextAlign align = TextAlign.left,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
    child: Text(
      dateToString(date),
      textAlign: align,
      overflow: TextOverflow.ellipsis, // Clip with ellipsis
      maxLines: 1, // Restrict to single line,
      style: const TextStyle(fontFamily: 'RobotoMono'),
    ),
  );
}

Widget buildFieldWidgetForText({
  final String text = '',
  final TextAlign align = TextAlign.left,
  final bool fixedFont = false,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
    child: Text(
      text, textAlign: align,
      overflow: TextOverflow.ellipsis, // Clip with ellipsis
      maxLines: 1, // Restrict to single line,
      style: TextStyle(fontFamily: fixedFont ? 'RobotoMono' : 'RobotoFlex'),
    ),
  );
}

Widget buildFieldWidgetForAmount({
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
        style: const TextStyle(fontFamily: 'RobotoMono'),
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
        shorthand
            ? (value is double ? getAmountAsShorthandText(value) : getNumberShorthandText(value))
            : value.toString(),
        textAlign: align,
        style: const TextStyle(fontFamily: 'RobotoMono'),
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

Widget buildWidgetFromTypeAndValue({
  required final dynamic value,
  required final FieldType type,
  required final TextAlign align,
  required final bool fixedFont,
  String currency = Constants.defaultCurrency,
}) {
  switch (type) {
    case FieldType.numeric:
      if (value is String) {
        return buildFieldWidgetForText(text: value, align: align, fixedFont: true);
      }
      return buildFieldWidgetForNumber(value: value as num, shorthand: false, align: align);
    case FieldType.numericShorthand:
      return buildFieldWidgetForNumber(value: value as num, shorthand: true, align: align);
    case FieldType.amount:
      if (value is String) {
        return buildFieldWidgetForText(text: value, align: align, fixedFont: true);
      }
      if (value is MoneyModel) {
        return Row(
          children: [
            const Spacer(), // align right
            MoneyWidget(amountModel: value),
          ],
        );
      }
      return buildFieldWidgetForAmount(value: value, shorthand: false, align: align, currency: currency);
    case FieldType.amountShorthand:
      return buildFieldWidgetForAmount(value: value, shorthand: true, align: align);
    case FieldType.widget:
      return Center(child: value as Widget);
    case FieldType.date:
      if (value is String) {
        return buildFieldWidgetForText(text: value, align: align, fixedFont: true);
      }
      return buildFieldWidgetForDate(date: value, align: align);
    case FieldType.text:
    default:
      return buildFieldWidgetForText(text: value.toString(), align: align, fixedFont: fixedFont);
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
