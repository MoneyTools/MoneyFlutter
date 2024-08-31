import 'package:flutter_test/flutter_test.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';

void main() {
  group('numbers Function Tests', () {
    test('test_should_round_positive_decimal_value', () {
      // Arrange
      double value = 3.14159;
      int places = 2;

      // Act
      double result = roundToDecimalPlaces(value, places);

      // Assert
      expect(result, equals(3.14));
    });

    test('trimToFiveDecimalPlaces', () {
      // Arrange
      double value = 3.14159265359;

      // Act
      double result = trimToFiveDecimalPlaces(value);

      // Assert
      expect(result, equals(3.14159));
    });
  });
}
