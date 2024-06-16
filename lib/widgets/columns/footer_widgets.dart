import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/widgets/gaps.dart';

Widget getFooterForDateRange(final DateRange dateRange) {
  TextStyle styleSmall = TextStyle(
    fontSize: 10,
    color: getColorFromState(ColorState.disabled),
  );
  return IntrinsicWidth(
    child: Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(dateToString(dateRange.min), style: styleSmall),
              Text(dateToString(dateRange.max), style: styleSmall),
            ],
          ),
        ),
        gapMedium(),
        Text(
          dateRange.toStringDuration().replaceAll(' ', '\n'),
          style: styleSmall,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget getFooterForAmount(final double amount) {
  TextStyle style = TextStyle(
    color: colorBasedOnValue(amount),
    fontFamily: 'RobotoMono',
  );

  if (isSmallConsidredSmallValue(amount)) {
    return Text('\$${getAmountAsShorthandText(amount)}', style: style);
  }
  return Text(Currency.getAmountAsStringUsingCurrency(amount), style: style);
}

Widget getFooterForInt(final num value) {
  TextStyle style = TextStyle(
    color: colorBasedOnValue(value),
    fontFamily: 'RobotoMono',
  );

  if (isSmallConsidredSmallValue(value)) {
    return Text(getNumberShorthandText(value), style: style);
  }
  return Text(getIntAsText(value.toInt()), style: style);
}

bool isSmallConsidredSmallValue(final num value) {
  return isBetween(value, -10000, 10000);
}
