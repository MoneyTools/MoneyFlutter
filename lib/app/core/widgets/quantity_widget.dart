import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/helpers/string_helper.dart';

/// Formatted text using the supplied currency code and optional the currency/country flag
class QuantifyWidget extends StatelessWidget {
  /// Constructor
  const QuantifyWidget({
    required this.quantity,
    super.key,
    this.align = TextAlign.right,
  });

  final TextAlign align;

  /// Amount to display
  final double quantity;

  @override
  Widget build(final BuildContext context) {
    return Text(
      formatDoubleTimeZeroFiveNine(quantity, showPlusSign: true),
      textAlign: align,
      style: TextStyle(
        fontFamily: 'RobotoMono',
        color: isAlmostZero(quantity) ? Colors.grey.withOpacity(0.5) : null,
      ),
    );
  }
}
