import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:money/app/core/helpers/date_helper.dart';

void main() {
  test('geDateAndTimeAsText returns empty string for null DateTime', () {
    // Arrange
    const DateTime? dateTime = null;

    // Act
    final result = dateToDateTimeString(dateTime);

    // Assert
    expect(result, isEmpty);
  });

  test('geDateAndTimeAsText formats non-null DateTime correctly', () {
    // Arrange
    final dateTime = DateTime(2023, 04, 15, 10, 30, 00);

    // Act
    final result = dateToDateTimeString(dateTime);

    // Assert
    expect(result, '2023-04-15 10:30:00.000');
  });

  test('attempt to parse date formats', () {
    // ISO

    var parsedDate = attemptToGetDateFromText('2019-12-31');
    expect(parsedDate!.year, 2019);
    expect(parsedDate.month, 12);
    expect(parsedDate.day, 31);

    // USA MM/dd/yyyy
    parsedDate = attemptToGetDateFromText('2/27/2024');
    expect(parsedDate!.year, 2024);
    expect(parsedDate.month, 2);
    expect(parsedDate.day, 27);

    // USA MM/dd/yy
    parsedDate = attemptToGetDateFromText('2/3/20');
    expect(parsedDate!.year, 2020);
    expect(parsedDate.month, 2);
    expect(parsedDate.day, 3);

    // Europe dd/MM/yyyy
    parsedDate = attemptToGetDateFromText('2/3/2000');
    expect(parsedDate!.year, 2000);
    expect(parsedDate.month, 2);
    expect(parsedDate.day, 3);

    // Europe dd/MM/yyyy
    parsedDate = DateFormat('dd/MM/yyyy').tryParse('27/01/2024');
    expect(parsedDate!.year, 2024);
    expect(parsedDate.month, 1);
    expect(parsedDate.day, 27);
  });
}
