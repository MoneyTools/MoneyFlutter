import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/helpers/string_helper.dart';

/// Formatted text using the supplied currency code and optional the currency/country flag
class QuantifyWidget extends StatelessWidget {

  /// Constructor
  const QuantifyWidget({
    super.key,
    required this.quantity,
    this.align = TextAlign.right,
  });
  /// Amount to display
  final double quantity;
  final TextAlign align;

  @override
  Widget build(final BuildContext context) {
    return Text(
      formatDoubleTimeZeroFiveNine(quantity),
      textAlign: align,
      style: TextStyle(
        fontFamily: 'RobotoMono',
        color: trimToFiveDecimalPlaces(quantity) == 0 ? Colors.grey.withOpacity(0.8) : null,
      ),
    );
  }
}
