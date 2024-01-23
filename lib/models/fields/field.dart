import 'package:flutter/widgets.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/data_io/data.dart';

dynamic defaultCallbackValue(final dynamic instance) => '';

class Field<C, T> {
  late T value;
  String name;
  String serializeName;
  FieldType type;
  TextAlign align;
  bool useAsColumn;
  bool useAsDetailPanels;
  bool readOnly = true;
  bool isMultiLine = false;
  int importance;
  dynamic Function(C) valueFromInstance;
  dynamic Function(C) valueForSerialization;
  int Function(C, C, bool)? sort;

  // void operator = (final T newValue) {
  //   _value = newValue;
  // };

  Field({
    this.type = FieldType.text,
    this.align = TextAlign.left,
    this.name = '',
    this.serializeName = '',
    required final T defaultValue,
    this.importance = -1,
    this.valueFromInstance = defaultCallbackValue,
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
          valueFromInstance = (final C c) => getCurrencyText(value as double);
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
        return getCurrencyText(value as double);
      case FieldType.amountShorthand:
        return getNumberAsShorthandText(value as double);
      case FieldType.text:
      default:
        return value.toString();
    }
  }

  Widget getWidget(final C objectInstance) {
    return buildWidgetFromTypeAndValue(
      type,
      valueFromInstance(objectInstance),
      align,
    );
  }

  static Widget buildWidgetFromTypeAndValue(
    final FieldType type,
    final dynamic liveValue,
    final TextAlign align,
  ) {
    switch (type) {
      case FieldType.numeric:
        return buildFieldWidgetForNumber(value: liveValue as num, shorthand: false, align: align);
      case FieldType.numericShorthand:
        return buildFieldWidgetForNumber(value: liveValue as num, shorthand: true, align: align);
      case FieldType.amount:
        return buildFieldWidgetForCurrency(value: liveValue, shorthand: false, align: align);
      case FieldType.amountShorthand:
        return buildFieldWidgetForCurrency(value: liveValue, shorthand: true, align: align);
      case FieldType.widget:
        return Expanded(child: Center(child: liveValue as Widget));
      case FieldType.text:
      default:
        return buildFieldWidgetForText(text: liveValue.toString(), align: align);
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
          align: TextAlign.right,
          type: FieldType.amount,
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
  }) : super(
          defaultValue: '',
          align: TextAlign.left,
          type: FieldType.text,
        );
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
    super.importance,
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

  list.sort((final Field<dynamic, dynamic> a, final Field<dynamic, dynamic> b) {
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
  return Expanded(
      child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: textAlignToAlignment(align),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
            child: Text(text, textAlign: align),
          )));
}

Widget buildFieldWidgetForCurrency({
  final dynamic value = 0,
  final bool shorthand = false,
  final TextAlign align = TextAlign.right,
}) {
  return Expanded(
      child: FittedBox(
    fit: BoxFit.scaleDown,
    alignment: textAlignToAlignment(align),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: Text(
        shorthand ? getNumberAsShorthandText(value as num) : getCurrencyText(value as double),
        textAlign: align,
      ),
    ),
  ));
}

Widget buildFieldWidgetForNumber({
  final num value = 0,
  final bool shorthand = false,
  final TextAlign align = TextAlign.right,
}) {
  return Expanded(
      child: FittedBox(
    fit: BoxFit.scaleDown,
    alignment: textAlignToAlignment(align),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: Text(
        shorthand ? getNumberAsShorthandText(value) : getNumberText(value),
        textAlign: align,
      ),
    ),
  ));
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
  widget,
}
