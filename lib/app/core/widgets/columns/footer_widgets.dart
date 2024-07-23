import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/helpers/ranges.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/widgets.dart';
import 'package:money/app/data/models/money_objects/currencies/currency.dart';

Widget getFooterForDateRange(final DateRange dateRange) {
  return Expanded(
    child: LayoutBuilder(
      builder: (context, constraints) {
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
      },
    ),
  );
}

Widget getFooterForAmount(final double amount, {final String prefix = ''}) {
  TextStyle style = TextStyle(
    color: colorBasedOnValue(amount),
    fontFamily: 'RobotoMono',
  );

  if (isSmallValue(amount)) {
    return scaleDown(Text(prefix + Currency.getAmountAsStringUsingCurrency(amount), style: style));
  }
  return scaleDown(Text('$prefix\$${getAmountAsShorthandText(amount)}', style: style));
}

Widget getFooterForInt(final num value, {final bool applyColorBasedOnValue = true, final String prefix = ''}) {
  TextStyle style = TextStyle(
    color: applyColorBasedOnValue ? colorBasedOnValue(value) : null,
    fontFamily: 'RobotoMono',
  );

  if (isSmallValue(value)) {
    return scaleDown(Text(prefix + getIntAsText(value.toInt()), style: style));
  }
  return scaleDown(Text(prefix + getNumberShorthandText(value), style: style));
}

bool isSmallValue(final num value) {
  return isBetween(value, -10000, 10000);
}
