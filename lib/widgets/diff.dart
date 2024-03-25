import 'package:flutter/material.dart';

Widget diffTextOldValue(final String text) {
  return diffText(
    text,
    Colors.red.withOpacity(0.3), // Transparent red background color
    Colors.red, // Color for old value
    true,
  );
}

Widget diffTextNewValue(final String text) {
  return diffText(
    text,
    Colors.green.withOpacity(0.3), // Transparent red background color
    Colors.green, // Color for old value
    false,
  );
}

Widget diffText(
  final String text,
  final Color backgroundColor,
  final Color textColor,
  final bool lineTrough,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4.0),
    child: Chip(
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      label: Text(text),
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(
        fontSize: 10,
        color: textColor,
        decoration: lineTrough ? TextDecoration.lineThrough : null, // Strike out text
      ),
    ),
  );
}
