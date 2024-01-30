import 'package:flutter/cupertino.dart';
import 'package:money/models/money_objects/currencies/currency.dart';

/// Formatted text using the supplied currency code and optional the currency/country flag
class Amount extends StatelessWidget {
  /// Amount to display
  final double value;

  /// USD | CAD | GBP
  final String iso4217;

  /// Constructor
  const Amount(this.value, this.iso4217, {super.key});

  @override
  Widget build(final BuildContext context) {
    return Row(
      children: [
        Text(Currency.getCurrencyText(value)),
        const SizedBox(width: 10),
        Currency.buildCurrencyWidget(iso4217),
      ],
    );
  }
}
