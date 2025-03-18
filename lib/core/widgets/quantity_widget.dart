import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/helpers/string_helper.dart';

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
    final TextStyle style = TextStyle(
      fontFamily: 'RobotoMono',
      color: getTextColorToUseQuantity(quantity),
      fontWeight: FontWeight.w900,
    );

    final String originalString = formatDoubleUpToFiveZero(
      quantity,
      showPlusSign: true,
    );

    final int leftSideOfDecimalPoint = quantity.truncate();
    String leftSideOfDecimalPointAsString = '';
    if (leftSideOfDecimalPoint != 0) {
      leftSideOfDecimalPointAsString = formatDoubleUpToFiveZero(
        leftSideOfDecimalPoint.toDouble(),
        showPlusSign: true,
      );
    }
    final String rightOfDecimalPoint = originalString.substring(
      leftSideOfDecimalPointAsString.length,
    );

    return SelectableText.rich(
      maxLines: 1,
      textAlign: align,
      TextSpan(
        style: style,
        children: <InlineSpan>[
          TextSpan(text: leftSideOfDecimalPointAsString),
          if (rightOfDecimalPoint.isNotEmpty)
            TextSpan(
              text: rightOfDecimalPoint,
              style: const TextStyle(fontSize: 11),
            ),
        ],
      ),
    );
  }
}
