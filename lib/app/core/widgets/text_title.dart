import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';

class TextTitle extends StatelessWidget {
  const TextTitle(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: getTextTheme(context).headlineSmall!.copyWith(color: getColorTheme(context).onSurface),
    );
  }
}
