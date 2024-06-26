import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/data/models/money_model.dart';
import 'package:money/app/data/models/money_objects/currencies/currency.dart';

/// Formatted text using the supplied currency code and optional the currency/country flag
class MoneyWidget extends StatelessWidget {
  /// Constructor
  const MoneyWidget({
    super.key,
    required this.amountModel,
    this.asTile = false,
  });

  /// Amount to display
  final MoneyModel amountModel;
  final bool asTile;

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
    return SelectableText(
      maxLines: 1,
      Currency.getAmountAsStringUsingCurrency(
        isAlmostZero((amountModel.toDouble())) ? 0.00 : amountModel.toDouble(),
        iso4217code: amountModel.iso4217,
      ),
      textAlign: TextAlign.right,
      style: TextStyle(
        fontFamily: 'RobotoMono',
        color: getTextColorToUse(amountModel.toDouble(), amountModel.autoColor),
        fontSize: asTile ? getTextTheme(context).titleMedium!.fontSize : null,
      ),
    );
  }
}

Color? getTextColorToUse(
  final double amount,
  final bool autoColor,
) {
  if (autoColor) {
    if (isAlmostZero(amount)) {
      return getColorFromState(ColorState.disabled);
    }
    if (amount < 0) {
      return getColorFromState(ColorState.error);
    } else {
      return getColorFromState(ColorState.success);
    }
  }
  return null;
}
