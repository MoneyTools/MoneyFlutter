import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';

// ignore: must_be_immutable
class TokenText extends StatelessWidget {
  TokenText({super.key, required this.text}) {
    tokens = text.split(':');
  }

  final String text;
  List<String> tokens = [];

  @override
  Widget build(BuildContext context) {
    final Widget separetor = Text(
      ':',
      style: TextStyle(color: getColorTheme(context).primary),
    );
    const parentTextStyle = TextStyle(fontSize: 10);
    final List<Widget> widgets = [];

    for (final token in tokens) {
      if (token == tokens.last) {
        widgets.add(Expanded(
          child: Text(
            token,
            softWrap: false,
          ),
        ));
      } else {
        widgets.add(Opacity(opacity: 0.8, child: Text(token, style: parentTextStyle)));
        widgets.add(separetor);
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: widgets,
    );
  }
}
