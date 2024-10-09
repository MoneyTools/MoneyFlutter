import 'package:money/core/widgets/gaps.dart';
import 'package:money/core/widgets/widgets.dart';

class CurrencyLabel extends StatelessWidget {
  const CurrencyLabel({
    required this.threeLetterCurrencySymbol,
    required this.flagId,
    super.key,
  });

  final String flagId;
  final String threeLetterCurrencySymbol;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return '$threeLetterCurrencySymbol:$flagId';
  }

  @override
  Widget build(BuildContext context) {
    return scaleDown(
      Semantics(
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
}
