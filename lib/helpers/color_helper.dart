import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';

/// return the inverted color
Color invertColor(final Color color) {
  // Calculate inverted color by subtracting each color channel from 255
  int invertedRed = 255 - color.red;
  int invertedGreen = 255 - color.green;
  int invertedBlue = 255 - color.blue;

  // Return the inverted color
  return Color.fromRGBO(invertedRed, invertedGreen, invertedBlue, 1.0);
}

Color contrastColor(Color color) {
  // Calculate the luminance of the color
  final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

  // Determine whether to make the contrast color black or white based on the luminance
  final contrastColor = luminance > 0.5 ? Colors.black : Colors.white;

  return contrastColor;
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

String colorToHexString(final Color color, {bool alphaFirst = false, bool includeAlpha = true}) {
  final String red = color.red.toRadixString(16).padLeft(2, '0');
  final String green = color.green.toRadixString(16).padLeft(2, '0');
  final String blue = color.blue.toRadixString(16).padLeft(2, '0');
  final String alpha = color.alpha.toRadixString(16).padLeft(2, '0');
  if (includeAlpha == false) {
    return '#$red$green$blue';
  }
  if (alphaFirst) {
    return '#$alpha$red$green$blue';
  }
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

Widget colorBox(Color color, Color colorText) {
  return Container(
    color: color,
    width: 80,
    height: 80,
    margin: const EdgeInsets.all(10),
    child: Text(color.toString(), style: TextStyle(color: colorText)),
  );
}

Color addHintOfGreenToColor(Color color, [int hint = 50]) {
  // Calculate the new green value
  int newGreen = (color.green + hint).clamp(0, 255);

  // Return the new color with added green
  return Color.fromRGBO(color.red, newGreen, color.blue, color.opacity);
}

Color addHintOfRedToColor(Color color, [int hint = 50]) {
  // Calculate the new red value
  int newRed = (color.red + hint).clamp(0, 255);

  // Return the new color with added red
  return Color.fromRGBO(newRed, color.green, color.blue, color.opacity);
}

Pair<double, double> getHueAndDarkness(Color color) {
  // Convert the color to HSL
  HSLColor hslColor = HSLColor.fromColor(color);

  // Return the hue and darkness values
  return Pair<double, double>(hslColor.hue, 1 - hslColor.lightness);
}

Color hsvToColor(double hue, double brightness) {
  final Color color = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
  return adjustBrightness(color, brightness);
}

/// Adjusts the brightness of the input color to the specified value within the valid range (0.0 - 1.0).
Color adjustBrightness(Color color, double brightness) {
  // Ensure brightness is within valid range
  brightness = brightness.clamp(0.0, 1.0);

  // Convert color to HSL
  HSLColor hslColor = HSLColor.fromColor(color);

  // Adjust lightness component
  hslColor = hslColor.withLightness(brightness);

  // Convert back to RGB
  return hslColor.toColor();
}

/// Retrieves the hue value from the given Color object in the HSL color space.
double getHueFromColor(Color color) {
  // Convert color to HSL
  HSLColor hslColor = HSLColor.fromColor(color);

  // Extract hue value
  double hue = hslColor.hue;

  return hue;
}

/// Retrieves the hue and brightness values from the given Color object in the HSL color space.
Pair<double, double> getHueAndBrightnessFromColor(Color color) {
  // Convert color to HSL
  HSLColor hslColor = HSLColor.fromColor(color);

  // Extract hue and lightness values
  double hue = hslColor.hue;
  double brightness = hslColor.lightness;

  return Pair<double, double>(hue, brightness);
}
