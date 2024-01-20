import 'package:flutter/material.dart';

/// return the inverted color
Color invertColor(final Color color) {
  final int r = 255 - color.red;
  final int g = 255 - color.green;
  final int b = 255 - color.blue;

  return Color.fromARGB((color.opacity * 255).round(), r, g, b);
}

ThemeData getTheme(final BuildContext context) {
  return Theme.of(context);
}

TextTheme getTextTheme(final BuildContext context) {
  return getTheme(context).textTheme;
}

ColorScheme getColorTheme(final BuildContext context) {
  return getTheme(context).colorScheme;
}

/// convert a hex string value into a Flutter color
Color getColorFromString(final String hexColor) {
  String newHexColor = hexColor.trim().replaceAll("#", "");
  if (newHexColor.length == 6) {
    newHexColor = 'FF$newHexColor';
  }
  if (newHexColor.length == 8) {
    return Color(int.parse("0x$newHexColor"));
  }
  return Colors.transparent;
}

String colorToHexString(final Color color) {
  final String red = color.red.toRadixString(16).padLeft(2, '0');
  final String green = color.green.toRadixString(16).padLeft(2, '0');
  final String blue = color.blue.toRadixString(16).padLeft(2, '0');
  final String alpha = color.alpha.toRadixString(16).padLeft(2, '0');

  return '#$red$green$blue$alpha';
}
