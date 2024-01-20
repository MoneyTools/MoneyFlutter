import 'package:flutter/widgets.dart';
import 'package:money/helpers/string_helper.dart';

Map<String, Declare<dynamic, dynamic>> classToFieldMapping = <String, Declare<dynamic, dynamic>>{};

dynamic defaultCallbackValue(final dynamic instance) => '';

class Declare<C, T> {
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

  Declare({
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
    final String key = '$C.${getBestDescribingNameForDeclaration()}';
    classToFieldMapping[key] = this;

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

  String getBestDescribingNameForDeclaration() {
    if (serializeName.isNotEmpty) {
      return serializeName;
    }
    if (name.isNotEmpty) {
      return name;
    }
    return T.toString();
  }

  factory Declare.id() {
    return Declare<C, T>(serializeName: 'Id', defaultValue: -1 as T);
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
    final dynamic liveValue = valueFromInstance(objectInstance);

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

class DeclareId<C> extends Declare<C, int> {
  DeclareId({
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

class DeclareDouble<C> extends Declare<C, double> {
  DeclareDouble({
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

class DeclareString<C> extends Declare<C, String> {
  DeclareString({
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

class DeclareNoSerialized<C, T> extends Declare<C, T> {
  DeclareNoSerialized({
    required super.defaultValue,
    super.type,
    super.name,
    super.align,
    super.valueFromInstance,
    super.valueForSerialization,
  }) : super(serializeName: '');
}

List<Declare<C, dynamic>> getFieldsForClass<C>() {
  final List<Declare<C, dynamic>> list = <Declare<C, dynamic>>[];

  for (final MapEntry<String, Declare<dynamic, dynamic>> entry in classToFieldMapping.entries) {
    if (entry.key.startsWith('$C.')) {
      list.add(entry.value as Declare<C, dynamic>);
    }
  }

  list.sort((final Declare<dynamic, dynamic> a, final Declare<dynamic, dynamic> b) {
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

Declare<C, dynamic>? getFieldByNameForClass<C>(final String fieldName) {
  for (final MapEntry<Object, Object> entry in classToFieldMapping.entries) {
    if (entry.key == '$C.$fieldName') {
      return entry.value as Declare<C, dynamic>;
    }
  }
  return null;
}

class FieldDefinitionX<T> {
  String name;
  String? serializeName;
  final FieldType type;
  final TextAlign align;
  final int Function(T, T, bool)? sort;
  final bool useAsColumn;
  final bool readOnly;
  final bool isMultiLine;
  dynamic Function(T)? valueFromInstance;
  dynamic Function(T)? valueForSerialization;

  FieldDefinitionX({
    required this.name,
    this.valueFromInstance,
    this.serializeName,
    this.type = FieldType.text,
    this.align = TextAlign.left,
    this.valueForSerialization,
    this.sort,
    this.useAsColumn = true,
    this.readOnly = true,
    this.isMultiLine = false,
  }) {
    valueForSerialization ??= (final T t) => this.valueFromInstance!(t);
  }
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
