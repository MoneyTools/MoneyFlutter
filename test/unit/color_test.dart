import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/helpers/misc_helpers.dart';

void main() {
  group('invertColor Function Tests', () {
    test('test_invert_color_correct_inversion', () {
      const color = Color.fromRGBO(100, 150, 200, 1.0);
      const expectedInvertedColor = Color.fromRGBO(155, 105, 55, 1.0);
      final invertedColor = invertColor(color);

      expect(invertedColor, equals(expectedInvertedColor));
    });

    test('test_invert_color_edge_cases', () {
      const black = Color.fromRGBO(0, 0, 0, 1.0);
      const white = Color.fromRGBO(255, 255, 255, 1.0);
      final invertedBlack = invertColor(black);
      final invertedWhite = invertColor(white);

      expect(invertedBlack, equals(white));
      expect(invertedWhite, equals(black));
    });
  });

  group('contrastColor Function Tests', () {
    test('test_contrast_color_luminance_threshold', () {
      const lightColor = Color.fromRGBO(200, 200, 200, 1.0);
      const darkColor = Color.fromRGBO(50, 50, 50, 1.0);
      final contrastForLight = contrastColor(lightColor);
      final contrastForDark = contrastColor(darkColor);

      expect(contrastForLight, equals(Colors.black));
      expect(contrastForDark, equals(Colors.white));
    });
  });

  group('getHueAndBrightnessFromColor Function Tests', () {
    test('test_getHueAndBrightnessFromColor', () {
      // Arrange
      Color color = Colors.blue;

      // Act
      Pair<double, double> result = getHueAndBrightnessFromColor(color);

      // Assert
      expect(roundToDecimalPlaces(result.first, 1), equals(206.6));
      expect(roundToDecimalPlaces(result.second, 1), equals(0.5));
    });
  });
}
