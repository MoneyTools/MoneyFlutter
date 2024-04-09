import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/money_objects/currencies/currency.dart';

/// Formatted text using the supplied currency code and optional the currency/country flag
class Amount extends StatelessWidget {
  /// Amount to display
  final double value;

  /// USD | CAD | GBP
  final String iso4217;

  final bool showCurrency;
  final bool autoColor;

  /// Constructor
  const Amount(this.value, this.iso4217, {super.key, this.showCurrency = true, this.autoColor = false});

  @override
  Widget build(final BuildContext context) {
    if (showCurrency) {
      return Row(
        children: [
          amountAsText(),
          const SizedBox(width: 10),
          Currency.buildCurrencyWidget(iso4217),
        ],
      );
    } else {
      return amountAsText();
    }
  }

  Widget amountAsText() {
    return Text(
      Currency.getAmountAsStringUsingCurrency(value),
      style: TextStyle(fontFamily: 'RobotoMono', color: autoColor ? colorBasedOnValue(value) : null),
    );
  }
}
