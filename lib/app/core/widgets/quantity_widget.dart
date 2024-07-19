import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';

/// Formatted text using the supplied currency code and optional the currency/country flag
class QuantityWidget extends StatelessWidget {
  /// Constructor
  const QuantityWidget({
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
        color: getTextColorToUseQuantity(quantity),
      ),
    );
  }
}
