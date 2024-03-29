import 'package:intl/intl.dart';

String dateToString(final DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

String getDateAsText(final DateTime? date) {
  return dateAsIso8601OrDefault(date).split('T').first;
}

String dateAsIso8601OrDefault(final DateTime? value, {final String defaultValueIfNull = ''}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value.toIso8601String();
}

/// Try parsing the date string with each format
DateTime? attemptToGetDateFromText(final String text) {
  // Define a list of date formats to try
  List<String> dateFormats = [
    'yyyy-MM-dd', // ISO8601
    'MM/dd/yyyy', // USA
    'dd/MM/yyyy', // Europe
    'dd/MM/yy', // Europe
    'dd-MM-yy', // Europe
    // Add more formats as needed...
  ];

  DateTime? parsedDate;
  for (String format in dateFormats) {
    parsedDate = DateFormat(format).tryParse(text);
    if (parsedDate != null && parsedDate.year > 1990) {
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
