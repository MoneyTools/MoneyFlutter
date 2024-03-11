import 'package:flutter/widgets.dart';
import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/currencies/currency.dart';

class Field<C, T> {
  late T value;
  String name;
  String serializeName;
  FieldType type;
  String currency; // used for FieldType.amount
  ColumnWidth columnWidth;
  TextAlign align;
  bool useAsColumn;
  bool useAsDetailPanels;
  bool readOnly = true;
  bool isMultiLine = false;
  int importance;

  /// Get the value of the instance
  dynamic Function(C) valueFromInstance;

  /// Customize/override the edit widget
  Widget Function(C, Function onEdited)? getEditWidget;

  /// override the value edited
  dynamic Function(C, dynamic)? setValue;

  /// Get the value for storing the instance
  dynamic Function(C) valueForSerialization;
  int Function(C, C, bool)? sort;

  // void operator = (final T newValue) {
  //   _value = newValue;
  // };

  Field({
    this.type = FieldType.text,
    this.currency = Constants.defaultCurrency,
    this.align = TextAlign.left,
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
    final String key = '$C.${getBestFieldDescribingName()}';
    Data().mapClassToFields[key] = this;

    value = defaultValue;
    if (name.isEmpty) {
      name = serializeName;
    }

    if (valueFromInstance == defaultCallbackValue) {
      switch (this.type) {
        case FieldType.numeric:
          valueFromInstance = (final C c) => value as num;
          valueForSerialization = valueFromInstance;
        case FieldType.text:
          valueFromInstance = (final C objectInstance) => value.toString();
        case FieldType.amount:
          valueFromInstance = (final C c) => Currency.getCurrencyText(value as double, iso4217code: currency);
        case FieldType.date:
          valueFromInstance = (final C c) => getDateAsText(value as DateTime);
        default:
          //
          debugPrint('No match');
      }
    }
    if (valueForSerialization == defaultCallbackValue) {
      valueForSerialization = valueFromInstance;
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
        return (value as num).toString();
      case FieldType.numericShorthand:
        return getNumberAsShorthandText(value as num);
      case FieldType.amount:
        return Currency.getCurrencyText(value as double);
      case FieldType.amountShorthand:
        return getNumberAsShorthandText(value as double);
      case FieldType.text:
      default:
        return value.toString();
    }
  }
}

class FieldInt<C> extends Field<C, int> {
  FieldInt({
    super.importance,
    super.name,
    super.serializeName,
    super.valueFromInstance,
    super.valueForSerialization,
    super.useAsColumn,
    super.useAsDetailPanels,
    super.sort,
    super.columnWidth,
  }) : super(
          defaultValue: 0,
          align: TextAlign.right,
          type: FieldType.numeric,
        );
}

class FieldDouble<C> extends Field<C, double> {
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

class FieldAmount<C> extends Field<C, double> {
  FieldAmount({
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
          currency: Constants.defaultCurrency,
          align: TextAlign.right,
          type: FieldType.amount,
        );
}

class FieldDate<C> extends Field<C, DateTime?> {
  FieldDate({
    super.importance,
    super.name,
    super.serializeName,
    super.valueFromInstance,
    super.valueForSerialization,
    super.useAsColumn,
    super.useAsDetailPanels,
    super.sort,
  }) : super(
          defaultValue: null,
          align: TextAlign.center,
          type: FieldType.date,
          columnWidth: ColumnWidth.small,
        );
}

class FieldString<C> extends Field<C, String> {
  FieldString({
    super.importance,
    super.name,
    super.serializeName,
    super.valueFromInstance,
    super.valueForSerialization,
    super.useAsColumn = true,
    super.useAsDetailPanels = true,
    super.align = TextAlign.left,
  }) : super(
            defaultValue: '',
            type: FieldType.text,
            sort: (final C a, final C b, final bool ascending) {
              return sortByString(valueFromInstance(a), valueFromInstance(b), ascending);
            });
}

class DeclareNoSerialized<C, T> extends Field<C, T> {
  DeclareNoSerialized({
    required super.defaultValue,
    super.type,
    super.name,
    super.align,
    super.valueFromInstance,
    super.valueForSerialization,
  }) : super(serializeName: '');
}

class FieldId<C> extends Field<C, int> {
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

List<Field<C, dynamic>> getFieldsForClass<C>() {
  final List<Field<C, dynamic>> list = <Field<C, dynamic>>[];

  for (final MapEntry<String, Field<dynamic, dynamic>> entry in Data().mapClassToFields.entries) {
    if (entry.key.startsWith('$C.')) {
      list.add(entry.value as Field<C, dynamic>);
    }
  }

  list.sort((final Field<C, dynamic> a, final Field<C, dynamic> b) {
    int result = 0;

    if (a.importance == -1 && b.importance >= 0) {
      return 1;
    }

    if (b.importance == -1 && a.importance >= 0) {
      return -1;
    }

    result = a.importance.compareTo(b.importance);

    if (result == 0) {
      // secondary sorting order is based on [serializeName]
      return a.serializeName.compareTo(b.serializeName);
    }
    return result;
  });

  return list;
}

Field<C, dynamic>? getFieldByNameForClass<C>(final String fieldName) {
  for (final MapEntry<Object, Object> entry in Data().mapClassToFields.entries) {
    if (entry.key == '$C.$fieldName') {
      return entry.value as Field<C, dynamic>;
    }
  }
  return null;
}

Widget buildFieldWidgetForText({
  final String text = '',
  final TextAlign align = TextAlign.left,
}) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    alignment: textAlignToAlignment(align),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: Text(text, textAlign: align),
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
            ? getNumberAsShorthandText(value as num)
            : Currency.getCurrencyText(value as double, iso4217code: currency),
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
        shorthand ? getNumberAsShorthandText(value) : getNumberText(value),
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
    case FieldType.text:
    default:
      return buildFieldWidgetForText(text: value.toString(), align: align);
  }
}

dynamic defaultCallbackValue(final dynamic instance) => '';

enum ColumnWidth {
  hide, // 0
  tiny, // 1
  small, // 2
  normal, // 3
  large, // 4
  largest, // 5
}
