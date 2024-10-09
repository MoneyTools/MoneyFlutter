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
  });

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
    final double value = amountModel.toDouble();

    final style = TextStyle(
      fontFamily: 'RobotoMono',
      color: getTextColorToUse(value, amountModel.autoColor),
      fontSize: asTile ? getTextTheme(context).titleMedium!.fontSize : null,
      fontWeight: FontWeight.w900,
    );

    final valueAsString = Currency.getAmountAsStringUsingCurrency(
      isConsideredZero((value)) ? 0.00 : value,
      iso4217code: amountModel.iso4217,
    );

    final leftSideOfDecimalPoint = value.truncate();
    final leftSideOfDecimalPointAsString = Currency.getAmountAsStringUsingCurrency(
      leftSideOfDecimalPoint,
      iso4217code: amountModel.iso4217,
      decimalDigits: 0,
    );

    final rightOfDecimalPoint = valueAsString.substring(leftSideOfDecimalPointAsString.length);

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
            style: const TextStyle(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
