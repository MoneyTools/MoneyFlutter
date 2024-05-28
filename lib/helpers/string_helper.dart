import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

String getIntAsText(final int value) {
  return NumberFormat.decimalPattern().format(value);
}

String getNumberShorthandText(final num value) {
  return NumberFormat.compact().format(value);
}

String getAmountAsShorthandText(final num value, {final int decimalDigits = 0, final String symbol = ''}) {
  return NumberFormat.compactCurrency(
    decimalDigits: decimalDigits,
    symbol: symbol, // if you want to add currency symbol then pass that in this else leave it empty.
  ).format(value);
}

int stringCompareIgnoreCasing1(final String textA, final String textB) {
  return textA.toUpperCase().compareTo(textB.toUpperCase());
}

int stringCompareIgnoreCasing2(final String str1, final String str2) {
  final int minLength = min(str1.length, str2.length);

  for (int i = 0; i < minLength; i++) {
    final int result = str1[i].toLowerCase().compareTo(str2[i].toLowerCase());
    if (result != 0) {
      return result;
    }
  }
  if (str1.length == str2.length) {
    return 0;
  }
  if (str1.length > str2.length) {
    return 1;
  }
  return -1;
}

String getStringDelimitedStartEndTokens(
  final String input,
  final String start,
  final String end,
) {
  final String content = getStringContentBetweenTwoTokens(input, start, end);
  return start + content + end;
}

String getStringContentBetweenTwoTokens(
  final String input,
  final String start,
  final String end,
) {
  final int indexStart = input.indexOf(start);
  if (indexStart != -1) {
    final int indexEnd = input.indexOf(end);
    if (indexEnd != -1) {
      return input.substring(indexStart + start.length, indexEnd);
    }
  }
  return '';
}

/// Clean up input string by removing "white noise"
String getNormalizedValue(final String? s) {
  if (s == null) {
    return '';
  }

  return s.replaceAll('\r\n', ' ').replaceAll('\r', ' ').replaceAll('\n', ' ').trim();
}

Future<String> getDocumentDirectory() async {
  if (kIsWeb) {
    return '';
  }
  final Directory directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

/// return a ISO 3166-1 Alpha2  US | CA | ES
String getCountryFromLocale(final String locale) {
  if (locale.isEmpty) {
    return 'US'; // default to US
  }
  final tokens = locale.replaceAll('-', '_').split('_');
  return tokens.last;
}

String doubleToCurrency(final double value) {
  NumberFormat currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  // Format the double value as currency text
  return currencyFormatter.format(value);
}

String getInitials(String fullName) {
  return fullName.split(' ').map((word) => word[0].toUpperCase()).join('');
}

String shortenLongText(String fullName, [int maxLength = 5]) {
  assert(maxLength >= 0);
  if (fullName.length <= maxLength) {
    // No need to shorten
    return fullName;
  }

  final words = fullName.split(' ');
  if (words.length >= 2) {
    return words.map((word) => word[0].toUpperCase()).join('.');
  }
  return fullName.substring(0, maxLength);
}

List<String> getLinesFromTextBlob(final String inputString) {
  return inputString.trim().split(RegExp(r'\r?\n|\r'));
}

List<String> getColumnInCsvLine(final String csvLine) {
  List<String> items = csvLine.split(RegExp(r',|;(?=(?:[^"]*"[^"]*")*[^"]*$)'));
  // remove quotes around elements
  items = items.map((item) => item.replaceAll('"', '')).toList();
  return items;
}

String removeEmptyLines(String text) {
  // Split the text into lines
  List<String> lines = text.split('\n');

  // Filter out the empty lines
  List<String> nonEmptyLines = lines.where((line) => line.trim().isNotEmpty).toList();

  // Join the non-empty lines back together
  String result = nonEmptyLines.join('\n');

  return result;
}

String formatDoubleTrimZeros(double value) {
  final formatter = NumberFormat('#,##0.##', 'en_US');
  return formatter.format(value);
}

String formatDoubleTimeZeroFiveNine(double value) {
  final formatter = NumberFormat('#,##0.#####', 'en_US');
  return formatter.format(value);
}

int countOccurrences(String input, String char) {
  if (char.length != 1) {
    throw ArgumentError('The character to count must be a single character.');
  }

  int count = 0;
  for (int i = 0; i < input.length; i++) {
    if (input[i] == char) {
      count++;
    }
  }
  return count;
}

String getSingularPluralText(final String title, final int quantity, final String singular, final String plural) {
  return '$title ${quantity == 1 ? singular : plural}';
}

String escapeString(String input) {
  return input.replaceAll("'", "''");
}
