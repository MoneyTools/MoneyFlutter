import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';

class DateRange {
  DateRange({this.min, this.max});

  factory DateRange.fromStarEndYears(int yearStart, int yearEnd) {
    return DateRange(
      min: DateTime(yearStart, 1, 1),
      max: DateTime(yearEnd + 1).subtract(const Duration(microseconds: 1)),
    );
  }
  DateTime? min;
  DateTime? max;

  void clear() {
    min = null;
    max = null;
  }

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
    if (max == null || min == null) {
      return 0;
    }

    // Calculate the difference between the two dates
    final Duration difference = max!.difference(min!);

    // minimum 1 day
    if (difference.inDays < 1) {
      return 1;
    }

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
    return '${dateToYearString(min)} ($durationInYearsText) ${dateToYearString(max)}';
  }

  String toStringDays() {
    return '${dateToString(min)} ($durationInDaysText) ${dateToString(max)}';
  }

  String toStringDuration() {
    if (durationInDays >= 365) {
      return durationInYearsText;
    }
    return durationInDaysText;
  }

  String get durationInYearsText {
    return getSingularPluralText(
      getIntAsText(durationInYears),
      durationInYears,
      'year',
      'years',
    );
  }

  String get durationInDaysText {
    return getSingularPluralText(
      getIntAsText(durationInDays),
      durationInDays,
      'day',
      'days',
    );
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

/// Helper class to encapsulate a range of integers.
class IntRange {
  IntRange({required this.min, required this.max});
  int min;
  int max;

  /// Returns the span of the range, calculated as the difference between [max] and [min] plus one.
  int get span => max - min + 1;

  /// Increments the range by one, if possible.
  void increment(int maxLimit) {
    if (max + 1 <= maxLimit) {
      min++;
      max++;
    }
  }

  /// Decrements the range by one, if possible.
  void decrement(int minLimit) {
    if (min - 1 >= minLimit) {
      min--;
      max--;
    }
  }

  /// Checks if the range is valid.
  bool isValid() => min > 0 && max > 0 && span > 0;

  /// Updates the range with new values.
  void update(int newMin, int newMax) {
    min = newMin;
    max = newMax;
  }
}
