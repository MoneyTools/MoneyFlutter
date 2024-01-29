class DateRange {
  DateTime? min;
  DateTime? max;

  DateRange({this.min, this.max});

  void inflate(final DateTime dateTime) {
    min ??= dateTime;
    max ??= dateTime;

    if (dateTime.compareTo(min!) == -1) {
      min = dateTime;
    }

    if (dateTime.compareTo(max!) == 1) {
      max = dateTime;
    }
  }

  num valueOrZeroIfNull(final num? value) {
    if (value == null) {
      return 0;
    }
    return value;
  }

  num durationInYears() {
    if (min == null || max == null) {
      return 0;
    }

    return (valueOrZeroIfNull(max!.year) - valueOrZeroIfNull(min!.year)) + 1;
  }

  @override
  String toString() {
    return '${dateToString(min)} : ${dateToString(max)}';
  }

  String toStringYears() {
    return '${yearToString(min)} - ${yearToString(max)} (${durationInYears()})';
  }

  String dateToString(final DateTime? dateTime) {
    if (dateTime == null) {
      return '____-__-__';
    }

    return dateTime.toIso8601String();
  }

  String yearToString(final DateTime? dateTime) {
    if (dateTime == null) {
      return '____';
    }

    return dateTime.year.toString();
  }

  bool isBetween(final DateTime date) {
    return min!.isBefore(date) && max!.isAfter(date);
  }

  bool isBetweenEqual(final DateTime date) {
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
