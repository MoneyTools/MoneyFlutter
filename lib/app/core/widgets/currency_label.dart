import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/gaps.dart';

class CurrencyLabel extends StatelessWidget {
  const CurrencyLabel({
    required this.threeLetterCurrencySymbol,
    required this.flagId,
    super.key,
  });
  final String threeLetterCurrencySymbol;
  final String flagId;

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
