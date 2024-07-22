import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/money_widget.dart';
import 'package:money/app/core/widgets/quantity_widget.dart';
import 'package:money/app/data/models/money_objects/currencies/currency.dart';
import 'package:money/app/data/models/money_objects/money_object.dart';

export 'package:money/app/data/models/money_model.dart';

Widget buildFieldWidgetForAmount({
  final dynamic value = 0,
  final String currency = Constants.defaultCurrency,
  final bool shorthand = false,
  final TextAlign align = TextAlign.right,
}) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    alignment: textAlignToAlignment(align),
    child: Text(
      shorthand
          ? getAmountAsShorthandText(value as num)
          : Currency.getAmountAsStringUsingCurrency(
              value,
              iso4217code: currency,
            ),
      textAlign: align,
      style: TextStyle(
        fontFamily: 'RobotoMono',
        color: getTextColorToUse(value),
      ),
    ),
  );
}

Widget buildFieldWidgetForDate({
  final DateTime? date,
  final TextAlign align = TextAlign.left,
}) {
  return Text(
    dateToString(date),
    textAlign: align,
    overflow: TextOverflow.ellipsis, // Clip with ellipsis
    maxLines: 1, // Restrict to single line,
    style: const TextStyle(fontFamily: 'RobotoMono'),
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
    child: Text(
      shorthand
          ? (value is double ? getAmountAsShorthandText(value) : getNumberShorthandText(value))
          : value.toString(),
      textAlign: align,
      style: const TextStyle(fontFamily: 'RobotoMono'),
    ),
  );
}

Widget buildFieldWidgetForPercentage({
  final double value = 0,
}) {
  // 0.000 to 100.000%
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Opacity(
        opacity: value == 0 ? 0.4 : 1,
        child: Text(
          (value * 100).toStringAsFixed(3),
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontFamily: 'RobotoMono',
          ),
        ),
      ),
      const Opacity(
        opacity: 0.8,
        child: Text(
          ' %',
          style: TextStyle(fontSize: 9),
        ),
      ),
    ],
  );
}

Widget buildFieldWidgetForText({
  final String text = '',
  final TextAlign align = TextAlign.left,
  final bool fixedFont = false,
}) {
  return Text(
    text, textAlign: align,
    overflow: TextOverflow.ellipsis, // Clip with ellipsis
    maxLines: 1, // Restrict to single line,
    style: TextStyle(fontFamily: fixedFont ? 'RobotoMono' : 'RobotoFlex'),
  );
}

Widget buildWidgetFromTypeAndValue({
  required final dynamic value,
  required final FieldType type,
  required final TextAlign align,
  required final bool fixedFont,
  String currency = Constants.defaultCurrency,
}) {
  switch (type) {
    // Numeric
    case FieldType.numeric:
      if (value is String) {
        return buildFieldWidgetForText(
          text: value,
          align: align,
          fixedFont: true,
        );
      }
      return buildFieldWidgetForNumber(
        value: value as num,
        shorthand: false,
        align: align,
      );

    // Numeric shorthand  12K
    case FieldType.numericShorthand:
      return buildFieldWidgetForNumber(
        value: value as num,
        shorthand: true,
        align: align,
      );

    // Quantity
    case FieldType.quantity:
      return Row(
        children: [
          Expanded(
            child: (value is num)
                ? QuantityWidget(
                    quantity: value.toDouble(),
                    align: align,
                  )
                : Text(
                    value.toString(),
                    textAlign: align,
                  ),
          ),
        ],
      );

    case FieldType.percentage:
      return buildFieldWidgetForPercentage(value: value);

    // Amount
    case FieldType.amount:
      if (value is String) {
        return buildFieldWidgetForText(
          text: value,
          align: align,
          fixedFont: true,
        );
      }
      if (value is MoneyModel) {
        return Row(
          children: [
            const Spacer(), // align right
            MoneyWidget(amountModel: value),
          ],
        );
      }
      return buildFieldWidgetForAmount(
        value: value,
        shorthand: false,
        align: align,
        currency: currency,
      );

    // Amount short hand
    case FieldType.amountShorthand:
      return buildFieldWidgetForAmount(
        value: value,
        shorthand: true,
        align: align,
      );

    // Widget
    case FieldType.widget:
      return value as Widget;

    // Date
    case FieldType.date:
      if (value is String) {
        return buildFieldWidgetForText(
          text: value,
          align: align,
          fixedFont: true,
        );
      }
      // Adapt to availabl space
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: buildFieldWidgetForDate(date: value, align: align),
      );

    case FieldType.text:
    default:
      return buildFieldWidgetForText(
        text: value.toString(),
        align: align,
        fixedFont: fixedFont,
      );
  }
}

dynamic defaultCallbackValue(final dynamic instance) => '';

bool defaultCallbackValueTrue(final dynamic instance) => true;

bool defaultCallbackValueFalse(final dynamic instance) => false;

Field<dynamic>? getFieldDefinitionByName(
  final FieldDefinitions fields,
  final String nameToFind,
) {
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

/// This is the base class for all field types.
/// It defines common properties and methods that are shared across different field types.

typedef FieldDefinitions = List<Field<dynamic>>;

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

enum FooterType {
  none,
  count,
  countNotEmpty, // TODO   12/50 (24%) - meaning 12 rows out of 50 have data, should this be shown in Percentage?
  sum,
  average,
  range,
}

class Field<T> {
  Field({
    // Value related
    required final T defaultValue,
    this.name = '',
    this.serializeName = '',
    this.type = FieldType.text,
    this.align = TextAlign.left,
    this.useAsDetailPanels = defaultCallbackValueTrue,
    this.useAsColumn = true,
    this.columnWidth = ColumnWidth.normal,
    this.footer = FooterType.none,
    this.fixedFont = false,
    this.getValue = defaultCallbackValue,
    this.getValueForDisplay = defaultCallbackValue,
    // ignore: avoid_init_to_null
    this.getValueForReading = null,
    this.getValueForSerialization = defaultCallbackValue,
    this.getEditWidget,
    this.setValue,
    this.sort,
    this.importance = -1,
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
          sort = (
            final MoneyObject a,
            final MoneyObject b,
            final bool ascending,
          ) =>
              sortByValue(
                getValueForDisplay(a) as num,
                getValueForDisplay(b) as num,
                ascending,
              );
        case FieldType.amount:
          sort = (
            final MoneyObject a,
            final MoneyObject b,
            final bool ascending,
          ) =>
              sortByValue(
                getValueForDisplay(a).toDouble(),
                getValueForDisplay(b).toDouble(),
                ascending,
              );
        case FieldType.date:
          sort = (
            final MoneyObject a,
            final MoneyObject b,
            final bool ascending,
          ) =>
              sortByDate(
                getValueForDisplay(a),
                getValueForDisplay(b),
                ascending,
              );
        case FieldType.text:
        default:
          sort = (
            final MoneyObject a,
            final MoneyObject b,
            final bool ascending,
          ) =>
              sortByString(
                getValueForDisplay(a).toString(),
                getValueForDisplay(b).toString(),
                ascending,
              );
      }
    }
  }

  /// Customize/override the edit widget
  Widget Function(MoneyObject, Function(bool wasModified) onEdited)? getEditWidget;

  /// override the value edited
  dynamic Function(MoneyObject, dynamic)? setValue;

  /// Only need for FieldType.widget
  dynamic Function(MoneyObject)? getValueForReading;

  TextAlign align;
  ColumnWidth columnWidth;
  bool fixedFont = false;
  // indicate how to handle the column footer
  FooterType footer;

  /// Get the value
  dynamic Function(MoneyObject) getValue;

  /// Get the value of the instance
  dynamic Function(MoneyObject) getValueForDisplay;

  /// Get the value for storing the instance
  dynamic Function(MoneyObject) getValueForSerialization;

  int importance;
  // Static properties
  String name;

  String serializeName;
  FieldType type;
  bool useAsColumn;
  // This properties are evaluated against the instnace of the object
  bool Function(MoneyObject) useAsDetailPanels;

  int Function(MoneyObject, MoneyObject, bool)? sort;

  late T _value;

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
      case FieldType.percentage:
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
      return value as Widget;
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

  void setAmount(final dynamic newValue) {
    (this as FieldMoney).value.setAmount(newValue);
  }

  // ignore: unnecessary_getters_setters
  T get value {
    return _value;
  }

  set value(T v) {
    _value = v;
  }
}

class FieldDate extends Field<DateTime?> {
  FieldDate({
    super.importance,
    super.name,
    super.serializeName,
    super.getValueForDisplay,
    super.getValueForSerialization,
    super.setValue,
    super.useAsColumn,
    super.useAsDetailPanels,
    super.sort,
    super.columnWidth = ColumnWidth.tiny,
    super.getEditWidget,
  }) : super(
          defaultValue: null,
          align: TextAlign.left,
          type: FieldType.date,
          footer: FooterType.range,
        );
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

class FieldPercentage extends Field<double> {
  FieldPercentage({
    super.importance,
    super.name,
    super.serializeName,
    super.getValueForDisplay,
    super.getValueForSerialization,
    super.useAsColumn,
    super.defaultValue = 0.000,
    super.useAsDetailPanels,
    super.sort,
  }) : super(
          align: TextAlign.right,
          type: FieldType.percentage,
          fixedFont: true,
        );
}

class FieldId extends Field<int> {
  FieldId({
    super.importance = 0,
    super.getValueForDisplay,
    super.getValueForSerialization,
  }) : super(
          serializeName: 'Id',
          useAsColumn: false,
          useAsDetailPanels: defaultCallbackValueFalse,
          defaultValue: -1,
        );
}

class FieldInt extends Field<int> {
  FieldInt({
    super.importance,
    super.name,
    super.serializeName,
    super.getValueForDisplay,
    super.getValueForSerialization,
    super.getValueForReading,
    super.useAsColumn,
    super.columnWidth,
    super.useAsDetailPanels,
    super.defaultValue = -1,
    super.setValue,
    super.getEditWidget,
    super.sort,
    super.align = TextAlign.right,
    super.type = FieldType.numeric,
    super.footer = FooterType.sum,
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
    super.footer = FooterType.sum,
    super.useAsDetailPanels,
    super.sort,
  }) : super(
          defaultValue: MoneyModel(amount: 0.00, autoColor: true),
          align: TextAlign.right,
          type: FieldType.amount,
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
    super.footer = FooterType.sum,
    super.sort,
  });
}

class FieldString extends Field<String> {
  FieldString({
    super.importance,
    super.name,
    super.serializeName,
    super.getValueForDisplay,
    super.getValueForReading,
    super.getValueForSerialization,
    super.useAsColumn = true,
    super.columnWidth,
    super.useAsDetailPanels = defaultCallbackValueTrue,
    super.align = TextAlign.left,
    super.fixedFont = false,
    super.getEditWidget,
    super.setValue,
    super.type = FieldType.text,
    super.footer = FooterType.count,
    super.sort,
  }) : super(
          defaultValue: '',
        ) {
    if (sort == null) {
      super.sort = (final MoneyObject a, final MoneyObject b, final bool ascending) {
        return sortByString(
          getValueForDisplay(a),
          getValueForDisplay(b),
          ascending,
        );
      };
    }
  }
}

/// This enum defines the different types of fields supported
enum FieldType {
  text,
  numeric,
  numericShorthand,
  quantity,
  percentage,
  amount,
  amountShorthand,
  date,
  dateRange,
  toggle, // On/Off
  widget,
}
