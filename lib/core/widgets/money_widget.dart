import 'package:flutter/material.dart';
import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/helpers/misc_helpers.dart';
import 'package:money/data/models/money_model.dart';
import 'package:money/data/models/money_objects/currencies/currency.dart';

/// Formatted text using the supplied currency code and optional the currency/country flag
class MoneyWidget extends StatelessWidget {
  /// Constructor
  const MoneyWidget({
    super.key,
    required this.amountModel,
    this.asTile = false,
    this.asHeader = false,
  });

  factory MoneyWidget.fromDouble(double amount, {bool asTitle = false, bool asHeader = false}) {
    return MoneyWidget(
      amountModel: MoneyModel(
        amount: amount,
      ),
      asTile: asTitle,
      asHeader: asHeader,
    );
  }

  final bool asHeader;
  final bool asTile;

  /// Amount to display
  final MoneyModel amountModel;

  @override
  Widget build(final BuildContext context) {
    if (amountModel.showCurrency) {
      return Row(
        children: [
          _amountAsText(context),
          const SizedBox(width: 10),
          Currency.buildCurrencyWidget(amountModel.iso4217),
        ],
      );
    } else {
      return _amountAsText(context);
    }
  }

  Widget _amountAsText(final BuildContext context) {
    double value = amountModel.toDouble();
    if (!value.isFinite) {
      value = 0.00;
    }

    double? fontSize;
    if (asTile) {
      fontSize = getTextTheme(context).titleMedium!.fontSize!;
    }
    if (asHeader) {
      fontSize = getTextTheme(context).headlineLarge!.fontSize!;
    }

    final TextStyle style = TextStyle(
      fontFamily: 'RobotoMono',
      color: getTextColorToUse(value, amountModel.autoColor),
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
    );

    final String valueAsString = Currency.getAmountAsStringUsingCurrency(
      isConsideredZero((value)) ? 0.00 : value,
      iso4217code: amountModel.iso4217,
    );

    final int leftSideOfDecimalPoint = value.truncate();
    final String leftSideOfDecimalPointAsString = leftSideOfDecimalPoint.abs() == 0
        ? '' // No need to show leading zero
        : Currency.getAmountAsStringUsingCurrency(
            leftSideOfDecimalPoint,
            iso4217code: amountModel.iso4217,
            decimalDigits: 0,
          );

    final String rightOfDecimalPoint = valueAsString.substring(leftSideOfDecimalPointAsString.length);

    return SelectableText.rich(
      maxLines: 1,
      textAlign: TextAlign.right,
      TextSpan(
        style: style,
        children: [
          TextSpan(
            text: leftSideOfDecimalPointAsString,
          ),
          TextSpan(
            text: rightOfDecimalPoint,
            style: TextStyle(
              fontSize: fontSize != null ? fontSize * 0.8 : getTextTheme(context).bodySmall!.fontSize!,
            ),
          ),
        ],
      ),
    );
  }
}
