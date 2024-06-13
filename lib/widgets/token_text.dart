import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/constants.dart';

// ignore: must_be_immutable
class TokenText extends StatelessWidget {
  TokenText(this.text, {super.key}) {
    tokens = text.split(':');
  }

  final String text;
  List<String> tokens = [];

  @override
  Widget build(BuildContext context) {
    final Widget separetor = Padding(
      padding: const EdgeInsets.only(right: 3),
      child: Text(':', style: TextStyle(color: getColorTheme(context).primary)),
    );
    const parentTextStyle = TextStyle(fontSize: SizeForText.medium);
    final List<Widget> widgets = [];

    for (final String token in tokens) {
      if (token == tokens.last) {
        widgets.add(Expanded(
          child: Text(
            token,
            softWrap: false,
          ),
        ));
      } else {
        widgets.add(Opacity(opacity: 0.5, child: Text(token, style: parentTextStyle)));
        widgets.add(separetor);
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: widgets,
    );
  }
}
