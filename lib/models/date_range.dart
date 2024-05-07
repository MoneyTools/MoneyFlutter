import 'package:money/helpers/date_helper.dart';

class DateRange {
  DateTime? min;
  DateTime? max;

  DateRange({this.min, this.max});

  void inflate(final DateTime? dateTime) {
    if (dateTime != null) {
      min ??= dateTime;
      max ??= dateTime;

      if (dateTime.compareTo(min!) == -1) {
        min = dateTime;
      }

      if (dateTime.compareTo(max!) == 1) {
        max = dateTime;
      }
    }
  }

  int get durationInYears {
    if (hasNullDates) {
      return 0;
    }

    return (_valueOrZeroIfNull(max!.year) - _valueOrZeroIfNull(min!.year)) + 1;
  }

  int get durationInMonths {
    return durationInDays ~/ 30; // Close enough
  }

  int get durationInDays {
    // Calculate the difference between the two dates
    final Duration difference = max!.difference(min!);

    // Get the number of days from the difference
    return difference.inDays;
  }

  int _valueOrZeroIfNull(final int? value) {
    if (value == null) {
      return 0;
    }
    return value;
  }

  bool get hasNullDates {
    return min == null || max == null;
  }

  void ensureNoNullDates() {
    min ??= max;
    max ??= min;

    if (min == null && max == null) {
      min = max = DateTime.now();
    }
  }

  @override
  String toString() {
    return '${dateToString(min)} : ${dateToString(max)}';
  }

  String toStringYears() {
    return '${yearToString(min)} ($durationInYears years) ${yearToString(max)}';
  }

  bool isBetween(final DateTime date) {
    return min!.isBefore(date) && max!.isAfter(date);
  }

  bool isBetweenEqual(final DateTime? date) {
    if (date == null) {
      return false;
    }
    if (min == date || max == date) {
      return true;
    }
    return isBetween(date);
  }
}

/// Extension methods for [DateTime] class.
extension DateTimeExtension on DateTime {
  /// Returns start of a day.
  /// DateTime.now() -> 2019-09-30 17:15:20.294
  /// DateTime.now().startOfDay -> 2019-09-30 00:00:00.000
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns end of a day.
  /// DateTime.now() -> 2019-09-30 17:15:20.294
  /// DateTime.now().endOfDay -> 2019-09-30 23:59:59.999
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999, 999);
}
