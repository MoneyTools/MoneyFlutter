import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/money_objects/currencies/currency.dart';

Widget getFooterForDateRange(final DateRange dateRange) {
  return Expanded(
    child: LayoutBuilder(builder: (context, constraints) {
      bool showDates = constraints.maxWidth > 80;
      return DefaultTextStyle(
        style: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
          fontFamily: 'RobotoMono',
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDates) Text(dateToString(dateRange.min)),
            if (showDates) Text(dateToString(dateRange.max)),
            Text(
              dateRange.toStringDuration().padLeft(10),
              softWrap: true,
              maxLines: 2,
            ),
          ],
        ),
      );
    }),
  );
}

Widget getFooterForAmount(final double amount) {
  TextStyle style = TextStyle(
    color: colorBasedOnValue(amount),
    fontFamily: 'RobotoMono',
  );

  if (isSmallValue(amount)) {
    return Text(Currency.getAmountAsStringUsingCurrency(amount), style: style);
  }
  return Text('\$${getAmountAsShorthandText(amount)}', style: style);
}

Widget getFooterForInt(final num value) {
  TextStyle style = TextStyle(
    color: colorBasedOnValue(value),
    fontFamily: 'RobotoMono',
  );

  if (isSmallValue(value)) {
    return Text(getIntAsText(value.toInt()), style: style);
  }
  return Text(getNumberShorthandText(value), style: style);
}

bool isSmallValue(final num value) {
  return isBetween(value, -10000, 10000);
}
