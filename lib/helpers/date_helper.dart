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
    // Add more formats as needed...
  ];

  DateTime? parsedDate;
  for (String format in dateFormats) {
    parsedDate = DateFormat(format).tryParse(text);
    if (parsedDate != null) {
      break; // Stop parsing if a valid date is found
    }
  }
  return parsedDate;
}
