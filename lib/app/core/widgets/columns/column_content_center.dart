import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';

class HeaderContentCenter extends StatelessWidget {
  final String text;
  final Widget? trailingWidget;

  const HeaderContentCenter({super.key, required this.text, required this.trailingWidget});

  @override
  Widget build(BuildContext context) {
    final Widget textWidget = Text(
      text,
      softWrap: false,
      textAlign: TextAlign.center,
      overflow: TextOverflow.clip,
      style: getTextTheme(context).labelSmall!.copyWith(color: getColorTheme(context).secondary),
    );

    if (trailingWidget == null) {
      return textWidget;
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Flexible(child: textWidget), trailingWidget!]);
  }
}
