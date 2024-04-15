import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/helpers/string_helper.dart';

/// Formatted text using the supplied currency code and optional the currency/country flag
class QuantifyWidget extends StatelessWidget {
  /// Amount to display
  final double quantity;

  /// Constructor
  const QuantifyWidget({
    super.key,
    required this.quantity,
  });

  @override
  Widget build(final BuildContext context) {
    return Text(
      formatDoubleTimeZeroFiveNine(quantity),
      textAlign: TextAlign.right,
      style: TextStyle(
        fontFamily: 'RobotoMono',
        color: trimToFiveDecimalPlaces(quantity) == 0 ? Colors.grey.withOpacity(0.8) : null,
      ),
    );
  }
}
