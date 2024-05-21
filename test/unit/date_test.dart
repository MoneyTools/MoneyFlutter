import 'package:flutter_test/flutter_test.dart';
import 'package:money/helpers/date_helper.dart';

void main() {
  test('geDateAndTimeAsText returns empty string for null DateTime', () {
    // Arrange
    const DateTime? dateTime = null;

    // Act
    final result = geDateAndTimeAsText(dateTime);

    // Assert
    expect(result, isEmpty);
  });

  test('geDateAndTimeAsText formats non-null DateTime correctly', () {
    // Arrange
    final dateTime = DateTime(2023, 04, 15, 10, 30, 00);

    // Act
    final result = geDateAndTimeAsText(dateTime);

    // Assert
    expect(result, '2023-04-15 10:30:00.000');
  });
}
