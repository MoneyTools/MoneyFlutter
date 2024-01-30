import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

String getIntAsText(final int value) {
  return NumberFormat.decimalPattern().format(value);
}

String getCurrencyText(final double amount, [final int decimalDigits = 2]) {
  final NumberFormat formatCurrency = NumberFormat.simpleCurrency(decimalDigits: decimalDigits);

  return formatCurrency.format(amount);
}

String getNumberText(final num value) {
  return NumberFormat.compact().format(value);
}

String getNumberAsShorthandText(final num value, {final int decimalDigits = 0, final String symbol = ''}) {
  return NumberFormat.compactCurrency(
    decimalDigits: decimalDigits,
    symbol: symbol, // if you want to add currency symbol then pass that in this else leave it empty.
  ).format(value);
}

String getDateAsText(final DateTime date) {
  return date.toIso8601String().split('T').first;
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
