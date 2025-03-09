import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/helpers/date_helper.dart';
import 'package:money/core/helpers/misc_helpers.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/core/helpers/string_helper.dart';
import 'package:money/core/widgets/widgets.dart';
import 'package:money/data/models/money_objects/currencies/currency.dart';

Widget getFooterForDateRange(final DateRange dateRange) {
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final bool showDates = constraints.maxWidth > 80;
      return DefaultTextStyle(
        style: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
          fontFamily: 'RobotoMono',
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
  );
}

Widget getFooterForAmount(final double amount, {final String prefix = ''}) {
  final TextStyle style = TextStyle(
    color: colorBasedOnValue(amount),
    fontFamily: 'RobotoMono',
  );

  if (isSmallValue(amount)) {
    return scaleDown(
      Text(
        prefix + Currency.getAmountAsStringUsingCurrency(amount),
        style: style,
      ),
    );
  }
  return scaleDown(
    Text('$prefix\$${getAmountAsShorthandText(amount)}', style: style),
  );
}

Widget getFooterForInt(
  final num value, {
  final bool applyColorBasedOnValue = true,
  final String prefix = '',
}) {
  final TextStyle style = TextStyle(
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
