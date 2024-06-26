import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:path_provider/path_provider.dart';

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

String doubleToCurrency(final double value) {
  NumberFormat currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  // Format the double value as currency text
  return currencyFormatter.format(value);
}

String escapeString(String input) {
  return input.replaceAll("'", "''");
}

String formatDoubleTimeZeroFiveNine(double value) {
  final formatter = NumberFormat('#,##0.#####', 'en_US');
  return formatter.format(value);
}

String formatDoubleTrimZeros(double value) {
  final formatter = NumberFormat('#,##0.##', 'en_US');
  return formatter.format(value);
}

String getAmountAsShorthandText(
  final num value, {
  final int decimalDigits = 0,
  final String symbol = '',
}) {
  return NumberFormat.compactCurrency(
    decimalDigits: decimalDigits,
    symbol: symbol, // if you want to add currency symbol then pass that in this else leave it empty.
  ).format(value);
}

List<String> getColumnInCsvLine(final String csvLine) {
  List<String> items = csvLine.split(RegExp(r',|;(?=(?:[^"]*"[^"]*")*[^"]*$)'));
  // remove quotes around elements
  items = items.map((item) => item.replaceAll('"', '')).toList();
  return items;
}

/// return a ISO 3166-1 Alpha2  US | CA | ES
String getCountryFromLocale(final String locale) {
  if (locale.isEmpty) {
    return 'US'; // default to US
  }
  final tokens = locale.replaceAll('-', '_').split('_');
  return tokens.last;
}

Future<String> getDocumentDirectory() async {
  if (kIsWeb) {
    return '';
  }
  final Directory directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

String getInitials(String fullName) {
  return fullName.split(' ').map((word) => word[0].toUpperCase()).join('');
}

String getIntAsText(final int value) {
  return NumberFormat.decimalPattern().format(value);
}

List<List<String>> getLinesFromRawText(final String content) {
  List<List<String>> rows = [];
  List<String> currentRow = [];
  StringBuffer currentField = StringBuffer();
  bool inQuotes = false;

  for (int i = 0; i < content.length; i++) {
    var char = content[i];

    if (char == '"' && (i + 1 < content.length && content[i + 1] == '"')) {
      // Handle escaped quotes
      currentField.write('"');
      i++; // Skip the next quote
    } else if (char == '"') {
      inQuotes = !inQuotes; // Toggle the inQuotes state
    } else if (char == ',' && !inQuotes) {
      // End of a field
      currentRow.add(currentField.toString());
      currentField = StringBuffer();
    } else if ((char == '\n' || char == '\r') && !inQuotes) {
      // End of a row (handle both \n and \r\n)
      if (currentField.isNotEmpty || currentRow.isNotEmpty) {
        currentRow.add(currentField.toString());
        rows.add(currentRow);
        currentRow = [];
        currentField = StringBuffer();
      }
    } else {
      // Normal character
      currentField.write(char);
    }
  }

  // Add the last row if it exists
  if (currentField.isNotEmpty || currentRow.isNotEmpty) {
    currentRow.add(currentField.toString());
    rows.add(currentRow);
  }

  return rows;
}

/// Clean up input string by removing "white noise"
String getNormalizedValue(final String? s) {
  if (s == null) {
    return '';
  }

  return s.replaceAll('\r\n', ' ').replaceAll('\r', ' ').replaceAll('\n', ' ').trim();
}

String getNumberShorthandText(final num value) {
  return NumberFormat.compact().format(value);
}

String getSingularPluralText(
  final String title,
  final int quantity,
  final String singular,
  final String plural,
) {
  return '$title ${quantity == 1 ? singular : plural}';
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

String getStringDelimitedStartEndTokens(
  final String input,
  final String start,
  final String end,
) {
  final String content = getStringContentBetweenTwoTokens(input, start, end);
  return start + content + end;
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

int stringCompareIgnoreCasing1(final String textA, final String textB) {
  return textA.toUpperCase().compareTo(textB.toUpperCase());
}

int stringCompareIgnoreCasing2(final String str1, final String str2) {
  if (str1 == str2) {
    return 0;
  }

  final int length1 = str1.length;
  final int length2 = str2.length;

  final int minLength = min(length1, length2);

  for (int i = 0; i < minLength; i++) {
    final int result = str1[i].toLowerCase().compareTo(str2[i].toLowerCase());
    if (result != 0) {
      return result;
    }
  }

  return length1.compareTo(length2);
}

int compareStringsAsNumbers(final String a, final String b) {
  if (a.length == b.length) {
    return a.compareTo(b);
  }
  return a.length.compareTo(b.length);
}

int compareStringsAsAmount(final String a, final String b) {
  final valueA = attemptToGetDoubleFromText(a) ?? 0.00;
  final valueB = attemptToGetDoubleFromText(b) ?? 0.00;

  return valueA.compareTo(valueB);
}

String concat(
  final String existingValue,
  final String valueToConcat, [
  final String separatorIfNeeded = '; ',
  bool doNotConcactIfPresent = false,
]) {
  if (valueToConcat.isEmpty) {
    // Nothing to concat
    return existingValue;
  }

  if (existingValue.isEmpty) {
    return valueToConcat;
  } else {
    if (doNotConcactIfPresent && existingValue.contains(separatorIfNeeded)) {
      return existingValue;
    }
    return existingValue + separatorIfNeeded + valueToConcat;
  }
}

String removeUtf8Bom(String text) {
  const bom = '\u{FEFF}';
  if (text.startsWith(bom)) {
    return text.substring(1);
  }
  return text;
}
