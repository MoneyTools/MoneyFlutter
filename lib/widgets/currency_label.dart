import 'package:flutter/material.dart';
import 'package:money/widgets/gaps.dart';

class CurrencyLabel extends StatelessWidget {
  final String threeLetterCurrencySymbol;
  final String flagId;

  const CurrencyLabel({
    super.key,
    required this.threeLetterCurrencySymbol,
    required this.flagId,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Semantics(
        label: threeLetterCurrencySymbol,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(threeLetterCurrencySymbol),
            gapSmall(),
            Image.asset('assets/flags/$flagId.png', height: 10),
          ],
        ),
      ),
    );
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return '$threeLetterCurrencySymbol:$flagId';
  }
}
