import 'package:intl/intl.dart';

String dateToString(final DateTime? date) {
  if (date == null) {
    return '____-__-__';
  }
  return DateFormat('yyyy-MM-dd').format(date);
}

String dateTimeToString(final DateTime? dateTime) {
  if (dateTime == null) {
    return '____-__-__ __:__:__';
  }

  return dateTime.toIso8601String();
}

String yearToString(final DateTime? dateTime) {
  if (dateTime == null) {
    return '____';
  }

  return dateTime.year.toString();
}

/// Converts a nullable DateTime object to an ISO8601 string representation,
/// or returns a default value if the input is null.
///
/// This function takes a nullable DateTime object as input and returns a
/// string representation of the date and time in the ISO8601 format. If the
/// input DateTime object is null, the function returns a default value
/// specified by the `defaultValueIfNull` parameter.
///
/// Parameters:
/// - `value`: The nullable DateTime object to be converted to an ISO8601 string.
/// - `defaultValueIfNull`: The default value to be returned if the `value`
///   parameter is null. Defaults to an empty string `''`.
///
/// Returns:
/// - If `value` is not null, the ISO8601 string representation of the date and time.
/// - If `value` is null, the `defaultValueIfNull` value.
String dateAsIso8601OrDefault(final DateTime? value, {final String defaultValueIfNull = ''}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value.toIso8601String();
}

/// Attempts to parse a date string using a list of common date formats.
///
/// This function tries to parse the provided [text] string using a list of
/// predefined date formats. It returns the first valid [DateTime] object
/// found, or `null` if no valid date is found.
///
/// The supported date formats are:
/// - 'yyyy-MM-dd' (ISO8601)
/// - 'MM/dd/yyyy' (USA)
/// - 'dd/MM/yyyy' (Europe)
/// - 'dd/MM/yy' (Europe)
/// - 'dd-MM-yy' (Europe)
///
/// Example usage:
/// ```dart
/// final dateString = '2023-04-15';
/// final parsedDate = attemptToGetDateFromText(dateString);
/// if (parsedDate != null) {
///   print('Parsed date: $parsedDate');
/// } else {
///   print('Failed to parse date');
/// }
/// ```
///
/// @param text The date string to be parsed.
/// @return The parsed [DateTime] object, or `null` if no valid date is found.
DateTime? attemptToGetDateFromText(final String text) {
  // Define a list of date formats to try
  List<String> dateFormats = [
    'yyyy-MM-dd', // ISO8601
    'MM/dd/yyyy', // USA format 4 digit year
    'MM/dd/yy', // USA format 2 digit year
    'dd/MM/yyyy', // European format with full year
    'dd/MM/yy', // European format 2 digit year
    // Add more formats as needed...
  ];

  DateTime? parsedDate;
  for (String format in dateFormats) {
    parsedDate = DateFormat(format).tryParse(text);
    if (parsedDate != null && parsedDate.year >= 1900 && parsedDate.year <= 2099) {
      break; // Stop parsing if a valid date is found
    }
  }
  return parsedDate;
}

/// Input will look like this "20240103120000.000[-5:EST]"
///                            01234567890123456789012345
///                            0........10--------20_____
DateTime? parseQfxDataFormat(final String qfxDate) {
  // Extract date components
  try {
    // Extract date and time components
    final int year = int.parse(qfxDate.substring(0, 4));
    final int month = int.parse(qfxDate.substring(4, 6));
    final int day = int.parse(qfxDate.substring(6, 8));
    final int hour = int.parse(qfxDate.substring(8, 10));
    final int minute = int.parse(qfxDate.substring(10, 12));
    final int second = int.parse(qfxDate.substring(12, 14));

    // Create DateTime object
    DateTime dateTime = DateTime(year, month, day, hour, minute, second);

    // Import UTC based
    // dateTime = dateTime.toUtc();

    // // Extract time zone offset and abbreviation
    // final tokens = qfxDate.substring(19).split(':');
    // final int timeZoneOffset = int.parse(tokens[0]);
    //
    // // Adjust DateTime object with time zone offset
    // dateTime = dateTime.add(Duration(hours: timeZoneOffset));
    return dateTime;
  } catch (e) {
    return null;
  }
}

String geDateAndTimeAsText(final DateTime? dateTime) {
  String dateTimeAsText = '';
  if (dateTime != null) {
    dateTimeAsText += dateTime.toIso8601String().replaceAll('T', ' ');
  }
  return dateTimeAsText;
}

/// Return the newest of two given [DateTime] values.
///
/// If both [a] and [b] are `null`, this function will return `null`.
/// If one of the parameters is `null`, this function will return the non-null [DateTime] object.
/// If both parameters are non-null, this function will return the [DateTime] object that is the most recent.
///
/// @param a The first [DateTime] object to compare.
/// @param b The second [DateTime] object to compare.
/// @return The newest [DateTime] object, or `null` if both inputs are `null`.
DateTime? newestDate(final DateTime? a, final DateTime? b) {
  if (a == null) {
    return b;
  }
  if (b == null) {
    return a;
  }
  return a.isAfter(b) ? a : b;
}

/// Return the oldest of two given [DateTime] values.
///
/// If both [a] and [b] are `null`, this function will return `null`.
/// If one of the parameters is `null`, this function will return the non-null [DateTime] object.
/// If both parameters are non-null, this function will return the [DateTime] object that is the oldest.
///
/// @param a The first [DateTime] object to compare.
/// @param b The second [DateTime] object to compare.
/// @return The oldest [DateTime] object, or `null` if both inputs are `null`.
DateTime? oldestDate(final DateTime? a, final DateTime? b) {
  if (a == null) {
    return b;
  }
  if (b == null) {
    return a;
  }
  return a.isBefore(b) ? a : b;
}
