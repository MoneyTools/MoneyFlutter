import 'package:flutter/material.dart';
import 'package:money/app/data/models/constants.dart';

// ignore: must_be_immutable
class TokenText extends StatelessWidget {
  TokenText(
    this.text, {
    super.key,
    this.style = const TokenTextStyle(),
  }) {
    tokens = text.split(style.separator);
  }

  late final TokenTextStyle style;
  final String text;

  List<String> tokens = [];

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return text;
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle ancestors = TextStyle(fontSize: SizeForText.small);

    final Widget separetor = Padding(
      padding: EdgeInsets.only(
        left: style.separatorPaddingLeft,
        right: style.separatorPaddingRight,
      ),
      child: Text(style.separator, style: ancestors),
    );

    final List<Widget> widgets = [];

    for (final String token in tokens) {
      if (token == tokens.last) {
        widgets.add(
          Expanded(
            child: Text(
              token,
              softWrap: false,
              style: const TextStyle(fontSize: SizeForText.medium),
            ),
          ),
        );
      } else {
        widgets.add(Opacity(opacity: 0.8, child: Text(token, style: ancestors)));
        widgets.add(Opacity(opacity: 0.6, child: separetor));
      }
    }

    return IntrinsicWidth(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: widgets,
      ),
    );
  }
}

class TokenTextStyle {
  const TokenTextStyle({
    this.separator = ':',
    this.separatorPaddingLeft = 0,
    this.separatorPaddingRight = SizeForPadding.small,
    this.rigthAlign = false,
  });

  final bool rigthAlign;
  final String separator;
  final double separatorPaddingLeft;
  final double separatorPaddingRight;
}
