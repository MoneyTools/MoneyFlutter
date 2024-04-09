import 'package:flutter/material.dart';
import 'package:money/models/settings.dart';

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
  String newHexColor = hexColor.trim().replaceAll('#', '');
  if (newHexColor.length == 6) {
    newHexColor = 'FF$newHexColor';
  }
  if (newHexColor.length == 8) {
    return Color(int.parse('0x$newHexColor'));
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

TextStyle adjustOpacityOfTextStyle(final TextStyle textStyle, [final double opacity = 0.7]) {
  return textStyle.copyWith(
    color: textStyle.color!.withOpacity(opacity),
  );
}

Color addTintOfRed(Color originalColor, int tintStrength) {
  int red = originalColor.red + tintStrength;
  int green = originalColor.green;
  int blue = originalColor.blue;

  // Ensure red value stays within the valid range (0 to 255)
  red = red.clamp(0, 255);

  return Color.fromARGB(originalColor.alpha, red, green, blue);
}

Color addTintOfGreen(Color originalColor, int tintStrength) {
  int red = originalColor.red;
  int green = originalColor.green + tintStrength;
  int blue = originalColor.blue;

  // Ensure red value stays within the valid range (0 to 255)
  green = green.clamp(0, 255);

  return Color.fromARGB(originalColor.alpha, red, green, blue);
}

Color addTintOfBlue(Color originalColor, int tintStrength) {
  int red = originalColor.red;
  int green = originalColor.green;
  int blue = originalColor.blue + tintStrength;

  // Ensure red value stays within the valid range (0 to 255)
  blue = blue.clamp(0, 255);

  return Color.fromARGB(originalColor.alpha, red, green, blue);
}

Color colorBasedOnValue(final double value) {
  if (value > 0) {
    return Colors.green;
  }
  if (value < 0) {
    return Colors.red;
  }
  // value == 0
  return Colors.grey;
}

Widget colorBoxes(BuildContext context) {
  return Row(
    children: [
      TextButton(
          onPressed: () {
            Settings().useDarkMode = !Settings().useDarkMode;
          },
          child: Text(Settings().useDarkMode ? 'Dark' : 'Light')),
      colorBox(getColorTheme(context).background, getColorTheme(context).onBackground),
      colorBox(getColorTheme(context).primaryContainer, getColorTheme(context).onPrimaryContainer),
      colorBox(getColorTheme(context).secondaryContainer, getColorTheme(context).onSecondaryContainer),
      colorBox(getColorTheme(context).tertiaryContainer, getColorTheme(context).onTertiaryContainer),
    ],
  );
}

Widget colorBox(Color color, Color colorText) {
  return Container(
    color: color,
    width: 80,
    height: 80,
    margin: const EdgeInsets.all(10),
    child: Text(color.toString(), style: TextStyle(color: colorText)),
  );
}
