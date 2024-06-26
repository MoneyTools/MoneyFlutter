import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';

Widget buildTitle(BuildContext context, String text) {
  return Text(text, style: getTextTheme(context).headlineSmall);
}

Widget buildWarning(BuildContext context, String text) {
  return Text(
    text,
    style: getTextTheme(context).bodyMedium!.copyWith(color: Colors.orange),
  );
}
