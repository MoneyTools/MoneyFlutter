import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';

/// Returns the inverted color by subtracting each color channel from 255.
///
/// The [color] parameter represents the color to be inverted.
/// The red, green, and blue values of the [color] are subtracted from 255 to calculate the inverted color.
///
/// Returns the inverted color as a [Color] object.
/// The alpha value of the [color] is preserved in the inverted color.
/// The inverted color is created using the [Color.fromRGBO] constructor.
/// The [invertedRed], [invertedGreen], and [invertedBlue] values are used as the red, green, and blue channels of the inverted color, respectively.
/// The alpha value of the inverted color is set to 1.0.
///
Color invertColor(final Color color) {
  // Calculate inverted color by subtracting each color channel from 255
  int invertedRed = 255 - color.red;
  int invertedGreen = 255 - color.green;
  int invertedBlue = 255 - color.blue;

  // Return the inverted color
  return Color.fromRGBO(invertedRed, invertedGreen, invertedBlue, 1.0);
}

/// Calculates the contrast color based on the luminance of the input color.
///
/// The [color] parameter represents the color for which the contrast color will be calculated.
/// The luminance of the [color] is calculated using the formula: (0.299 * red + 0.587 * green + 0.114 * blue) / 255.
/// If the calculated luminance is greater than 0.5, the contrast color is set to black. Otherwise, it is set to white.
///
/// Returns the contrast color as a [Color] object.
///
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

/// Returns a Color object based on a given hexadecimal color string.
///
/// The hexadecimal color string can be in the format "#RRGGBB" or "#AARRGGBB".
/// If the hexadecimal color string is in the format "#RRGGBB", the alpha value is set to 255 (fully opaque).
/// If the hexadecimal color string is in the format "#AARRGGBB", the alpha value is parsed from the string.
/// If the hexadecimal color string is not in a valid format, the function returns Colors.transparent.
///
/// @param hexColor The hexadecimal color string to convert to a Color object.
/// @return The Color object representing the given hexadecimal color string, or Colors.transparent if the string is not in a valid format.
///
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

/// Converts a given [Color] object to a hexadecimal string representation.
///
/// The [color] parameter represents the color to be converted.
/// The [alphaFirst] parameter determines whether the alpha value should be placed before the RGB values in the hexadecimal string. By default, it is set to false.
/// The [includeAlpha] parameter determines whether the alpha value should be included in the hexadecimal string. By default, it is set to true.
///
/// Returns the hexadecimal string representation of the color, including the alpha value if specified.
/// If [includeAlpha] is false, the returned string will only contain the RGB values.
/// If [alphaFirst] is true, the returned string will have the alpha value placed before the RGB values.
/// Otherwise, the returned string will have the RGB values followed by the alpha value.
///
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

/// Adjusts the opacity of a [TextStyle] object.
///
/// The [textStyle] parameter represents the original [TextStyle] object.
/// The [opacity] parameter determines the opacity value to be applied to the [textStyle.color].
/// By default, the [opacity] is set to 0.7.
///
/// Returns a new [TextStyle] object with the adjusted opacity.
/// The [color] property of the new [TextStyle] object is set to the original [textStyle.color] with the specified [opacity] applied.
/// All other properties of the [textStyle] are preserved in the new [TextStyle] object.
///
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

/// Adds a tint of blue to the original color.
///
/// The [originalColor] parameter represents the original color to which the tint of blue will be added.
/// The [tintStrength] parameter determines the strength of the tint of blue to be added. It should be an integer value.
///
/// Returns a new [Color] object with the tint of blue added to the original color. The red and green values of the original color remain unchanged, while the blue value is increased by the [tintStrength] amount.
/// If the resulting blue value exceeds 255, it will be clamped to 255 to ensure it stays within the valid range (0 to 255).
///
Color addTintOfBlue(Color originalColor, int tintStrength) {
  int red = originalColor.red;
  int green = originalColor.green;
  int blue = originalColor.blue + tintStrength;

  // Ensure red value stays within the valid range (0 to 255)
  blue = blue.clamp(0, 255);

  return Color.fromARGB(originalColor.alpha, red, green, blue);
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

/// Returns a Pair object containing the hue and brightness values of the given color.
///
/// The color is first converted to HSL using the HSLColor.fromColor() method.
/// The hue value is extracted from the HSLColor object using the hue property.
/// The brightness value is calculated by subtracting the lightness value from 1.
///
/// @param color The color to extract the hue and brightness values from.
/// @return A Pair<double, double> object containing the hue and brightness values.
///
Pair<double, double> getHueAndBrightness(Color color) {
  HSLColor hslColor = HSLColor.fromColor(color);
  return Pair(hslColor.hue, 1 - hslColor.lightness);
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
