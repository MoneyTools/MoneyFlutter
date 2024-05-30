import 'package:flutter/material.dart';
import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/widgets/money_widget.dart';
import 'package:money/widgets/quantity_widget.dart';

export 'package:money/models/money_model.dart';

/// This is the base class for all field types.
/// It defines common properties and methods that are shared across different field types.

typedef FieldDefinitions = List<Field<dynamic>>;

Field<dynamic>? getFieldDefinitionByName(final FieldDefinitions fields, final String nameToFind) {
  for (final f in fields) {
    if (f.name == nameToFind) {
      return f;
    }
    if (f.serializeName == nameToFind) {
      return f;
    }
  }
  return null;
}

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
  int importance;

  /// Get the value of the instance
  dynamic Function(MoneyObject) getValueForDisplay;

  /// Get the value for storing the instance
  dynamic Function(MoneyObject) getValueForSerialization;

  /// Customize/override the edit widget
  Widget Function(MoneyObject, Function onEdited)? getEditWidget;

  /// override the value edited
  dynamic Function(MoneyObject, dynamic)? setValue;

  int Function(MoneyObject, MoneyObject, bool)? sort;

  Field({
    this.type = FieldType.text,
    this.align = TextAlign.left,
    this.columnWidth = ColumnWidth.normal,
    this.fixedFont = false,
    this.name = '',
    this.serializeName = '',

    // Value related
    required final T defaultValue,
    this.getValueForDisplay = defaultCallbackValue,
    this.getValueForSerialization = defaultCallbackValue,
    this.getEditWidget,
    this.setValue,
    this.importance = -1,
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
    if (getValueForDisplay == defaultCallbackValue) {
      switch (this.type) {
        case FieldType.numeric:
        case FieldType.quantity:
          getValueForDisplay = (final MoneyObject c) => value as num;
          getValueForSerialization = getValueForDisplay;
        case FieldType.text:
          getValueForDisplay = (final MoneyObject objectInstance) => value.toString();
        case FieldType.amount:
          getValueForDisplay = (final MoneyObject c) => MoneyWidget(amountModel: value as MoneyModel);
        case FieldType.date:
          getValueForDisplay = (final MoneyObject c) => dateToString(value as DateTime?);
        default:
          //
          debugPrint('No match');
      }
    }

    ///----------------------------------------------
    /// How to serialize this field
    if (getValueForSerialization == defaultCallbackValue) {
      // if there's no override function
      // apply the same data value to serial
      getValueForSerialization = getValueForDisplay;
    }

    ///----------------------------------------------
    /// How to Sort on this field
    if (sort == null) {
      // if no override on sorting fallback to type sorting
      switch (type) {
        case FieldType.numeric:
        case FieldType.numericShorthand:
        case FieldType.quantity:
        case FieldType.amountShorthand:
          sort = (final MoneyObject a, final MoneyObject b, final bool ascending) =>
              sortByValue(getValueForDisplay(a) as num, getValueForDisplay(b) as num, ascending);
        case FieldType.amount:
          sort = (final MoneyObject a, final MoneyObject b, final bool ascending) =>
              sortByValue(getValueForDisplay(a).amount, getValueForDisplay(b).amount, ascending);
        case FieldType.date:
          sort = (final MoneyObject a, final MoneyObject b, final bool ascending) =>
              sortByDate(getValueForDisplay(a), getValueForDisplay(b), ascending);
        case FieldType.text:
        default:
          sort = (final MoneyObject a, final MoneyObject b, final bool ascending) =>
              sortByString(getValueForDisplay(a).toString(), getValueForDisplay(b).toString(), ascending);
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
      case FieldType.quantity:
        return formatDoubleTimeZeroFiveNine(value);
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

  Widget getValueWidgetForDetailView(final dynamic value) {
    if (type == FieldType.widget) {
      return Row(children: [const Spacer(), value]);
    } else {
      return SelectableText(
        textAlign: TextAlign.right,
        getString(value),
        maxLines: 1,
        // overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    }
  }
}

class FieldInt extends Field<int> {
  FieldInt({
    super.importance,
    super.name,
    super.serializeName,
    super.getValueForDisplay,
    super.getValueForSerialization,
    super.useAsColumn,
    super.columnWidth,
    super.useAsDetailPanels,
    super.defaultValue = -1,
    super.setValue,
    super.getEditWidget,
    super.sort,
    super.align = TextAlign.right,
    super.type = FieldType.numeric,
  });
}

class FieldDouble extends Field<double> {
  FieldDouble({
    super.importance,
    super.name,
    super.serializeName,
    super.getValueForDisplay,
    super.getValueForSerialization,
    super.useAsColumn,
    super.defaultValue = 0.00,
    super.useAsDetailPanels,
    super.sort,
  }) : super(
          align: TextAlign.right,
          type: FieldType.numeric,
        );
}

class FieldQuantity extends Field<double> {
  FieldQuantity({
    super.importance,
    super.name,
    super.serializeName,
    super.getValueForDisplay,
    super.getValueForSerialization,
    super.setValue,
    super.useAsColumn,
    super.columnWidth = ColumnWidth.small,
    super.useAsDetailPanels,
    super.defaultValue = 0,
    super.align = TextAlign.right,
    super.type = FieldType.quantity,
    super.sort,
  });
}

class FieldMoney extends Field<MoneyModel> {
  FieldMoney({
    super.importance,
    super.name,
    super.serializeName,
    super.getValueForDisplay,
    super.getValueForSerialization,
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
    super.getValueForDisplay,
    super.getValueForSerialization,
    super.useAsColumn,
    super.useAsDetailPanels,
    super.sort,
    super.columnWidth = ColumnWidth.tiny,
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
    super.getValueForDisplay,
    super.getValueForSerialization,
    super.useAsColumn = true,
    super.columnWidth,
    super.useAsDetailPanels = true,
    super.align = TextAlign.left,
    super.fixedFont = false,
    super.getEditWidget,
    super.setValue,
    super.sort,
  }) : super(
          defaultValue: '',
          type: FieldType.text,
        ) {
    if (sort == null) {
      super.sort = (final MoneyObject a, final MoneyObject b, final bool ascending) {
        return sortByString(getValueForDisplay(a), getValueForDisplay(b), ascending);
      };
    }
  }
}

class FieldId extends Field<int> {
  FieldId({
    super.importance = 0,
    super.getValueForDisplay,
    super.getValueForSerialization,
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

/// This enum defines the different types of fields supported
enum FieldType {
  text,
  numeric,
  numericShorthand,
  quantity,
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

    case FieldType.quantity:
      return Row(
        children: [
          Expanded(
            child: QuantifyWidget(
              quantity: value,
              align: align,
            ),
          ),
        ],
      );

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

/// This enum defines the different column widths that can be used for displaying fields in a table or grid layout.
enum ColumnWidth {
  hide, // 0
  nano, // 1
  tiny, // 1
  small, // 2
  normal, // 3
  large, // 4
  largest, // 5
}
