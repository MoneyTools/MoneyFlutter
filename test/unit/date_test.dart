import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:money/core/helpers/date_helper.dart';

void main() {
  test('getDateAndTimeAsText returns empty string for null DateTime', () {
    // Arrange
    const DateTime? dateTime = null;

    // Act
    final result = dateToDateTimeString(dateTime);

    // Assert
    expect(result, isEmpty);
  });

  test('getDateAndTimeAsText formats non-null DateTime correctly', () {
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

  group('getPossibleDateFormats', () {
    test('returns an empty list for an empty string', () {
      expect(getPossibleDateFormats(''), isEmpty);
      expect(getPossibleDateFormats('   '), isEmpty);
    });

    test('returns correct formats for 4-digit year dates with dashes', () {
      expect(getPossibleDateFormats('2023-05-15'), ['yyyy-MM-dd', 'yyyy-MM-d']);
      expect(getPossibleDateFormats('05-15-2023'), ['MM-dd-yyyy', 'MM-d-yyyy']);
      expect(getPossibleDateFormats('15-05-2023'), ['dd-MM-yyyy', 'd-MM-yyyy']);
    });

    test('returns correct formats for 4-digit year dates with slashes', () {
      expect(getPossibleDateFormats('2023/05/15'), ['yyyy/MM/dd', 'yyyy/MM/d']);
      expect(getPossibleDateFormats('05/15/2023'), ['MM/dd/yyyy', 'MM/d/yyyy']);
      expect(getPossibleDateFormats('15/05/2023'), ['dd/MM/yyyy', 'd/MM/yyyy']);
    });

    test('returns correct formats for 2-digit year dates with dashes', () {
      expect(getPossibleDateFormats('23-05-15'), ['yy-MM-dd', 'dd-MM-yy', 'yy-MM-d', 'd-MM-yy']);
      expect(getPossibleDateFormats('05-15-23'), ['MM-dd-yy', 'MM-d-yy']);
      expect(getPossibleDateFormats('15-05-23'), ['yy-MM-dd', 'dd-MM-yy', 'yy-MM-d', 'd-MM-yy']);
    });

    test('returns correct formats for 2-digit year dates with slashes', () {
      expect(getPossibleDateFormats('23/05/15'), ['yy/MM/dd', 'dd/MM/yy', 'yy/MM/d', 'd/MM/yy']);
      expect(getPossibleDateFormats('05/15/23'), ['MM/dd/yy', 'MM/d/yy']);
      expect(getPossibleDateFormats('15/05/23'), ['yy/MM/dd', 'dd/MM/yy', 'yy/MM/d', 'd/MM/yy']);
    });

    test('returns multiple formats if the date string matches multiple formats', () {
      expect(getPossibleDateFormats('05/15/2023'), ['MM/dd/yyyy', 'MM/d/yyyy']);
      expect(getPossibleDateFormats('15/05/23'), ['yy/MM/dd', 'dd/MM/yy', 'yy/MM/d', 'd/MM/yy']);
    });

    test('returns an empty list for invalid date strings', () {
      expect(getPossibleDateFormats(''), isEmpty);
      expect(getPossibleDateFormats('hello'), isEmpty);
      expect(getPossibleDateFormats('1111/1111/1111'), isEmpty);
    });

    test('Relative dates', () {
      final dateOld = DateTime(1999, 1, 1, 23, 59, 59);
      final dateRecent = DateTime(2020, 1, 1);

      expect(oldestDate(dateOld, dateRecent), dateOld);
      expect(newestDate(dateOld, dateRecent), dateRecent);

      expect(isSameDateWithoutTime(dateOld, dateRecent), false);
      expect(isSameDateWithoutTime(dateOld, dateOld), true);

      expect(dateOld.dropTime.hour, 0);
    });

    test('Elsapse time', () {
      {
        final String result = getElapsedTime(DateTime.now().subtract(const Duration(seconds: 10)));
        expect(result, 'Just now');
      }

      final DateTime now = DateTime(2000, 1, 1);
      {
        final String result = getElapsedTime(relativeTo: now, now.subtract(const Duration(seconds: 61)));
        expect(result, '1 minute ago');
      }

      {
        final String result = getElapsedTime(relativeTo: now, now.subtract(const Duration(minutes: 5)));
        expect(result, '5 minutes ago');
      }

      {
        final String result = getElapsedTime(relativeTo: now, now.subtract(const Duration(minutes: 59)));
        expect(result, '59 minutes ago');
      }

      {
        final String result = getElapsedTime(relativeTo: now, now.subtract(const Duration(minutes: 60)));
        expect(result, '1 hour ago');
      }

      {
        final String result = getElapsedTime(relativeTo: now, now.subtract(const Duration(hours: 23, minutes: 59)));
        expect(result, '23 hours ago');
      }

      {
        final String result = getElapsedTime(relativeTo: now, now.subtract(const Duration(days: 1)));
        expect(result, '1 day ago');
      }

      {
        final String result = getElapsedTime(relativeTo: now, now.subtract(const Duration(days: 30)));
        expect(result, '1 month ago');
      }

      {
        final String result = getElapsedTime(relativeTo: now, now.subtract(const Duration(days: 45)));
        expect(result, '1 month, 15 days ago');
      }

      {
        final String result = getElapsedTime(relativeTo: now, now.subtract(const Duration(days: 365)));
        expect(result, '1 year ago');
      }

      {
        final String result = getElapsedTime(relativeTo: now, now.subtract(const Duration(days: 395)));
        expect(result, '1 year, 1 month ago');
      }

      {
        final String result = getElapsedTime(relativeTo: now, now.subtract(const Duration(days: 400)));
        expect(result, '1 year, 1 month, 5 days ago');
      }
    });
  });
}
