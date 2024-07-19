import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:url_launcher/url_launcher.dart';

/// Remove non-numeric characters from the currency text
double? attemptToGetDoubleFromText(String text) {
  text = text.trim();
  double? firstSimpleCase = double.tryParse(text);
  if (firstSimpleCase != null) {
    return firstSimpleCase;
  }

  // Remove non-numeric characters except for periods and commas
  String cleanedText = text.replaceAll(RegExp(r'[^\d.,]'), '');

  // Replace commas with periods for consistent parsing
  cleanedText = cleanedText.replaceAll(',', '.');

  // Remove any leading/trailing periods
  cleanedText = cleanedText.replaceAll(RegExp(r'^\.+|\.+$'), '');

  // If there are multiple periods, keep only the last one
  int lastIndex = cleanedText.lastIndexOf('.');
  if (lastIndex != -1) {
    String beforeDecimal = cleanedText.substring(0, lastIndex);
    beforeDecimal = beforeDecimal.replaceAll('.', '');
    cleanedText = beforeDecimal + cleanedText.substring(lastIndex);
  }

  // Parse the cleaned text into a double
  double? amount = double.tryParse(cleanedText);
  if (amount == null) {
    return null;
  }
  if (text.startsWith('-')) {
    return -amount;
  }
  return amount;
}

bool boolValueOrDefault(
  final bool? value, {
  final bool defaultValueIfNull = false,
}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

void copyToClipboardAndInformUser(
  final BuildContext context,
  final String textToCopy,
) {
  FlutterClipboard.copy(textToCopy).then(
    (_) => showSnackBar(context, 'Copied to clipboard'),
  );
}

DateTime dateValueOrDefault(
  final DateTime? value, {
  final DateTime? defaultValueIfNull,
}) {
  if (value == null) {
    return defaultValueIfNull ?? DateTime.now();
  }
  return value;
}

void debugLog(final String message) {
  if (kDebugMode) {
    print(message);
  }
}

double doubleValueOrDefault(
  final double? value, {
  final double defaultValueIfNull = 0,
}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

int intValueOrDefault(final int? value, {final int defaultValueIfNull = 0}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

bool isBetween(final num value, final num min, final num max) {
  return value > min && value < max;
}

bool isBetweenOrEqual(final num value, final num min, final num max) {
  return value >= min && value <= max;
}

bool isPlatformMobile() {
  return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}

bool isSmallDevice(final BuildContext context) {
  // Get the screen size
  final screenSize = MediaQuery.of(context).size;

  // Determine if the screen width is smaller than a certain threshold
  return screenSize.width < 600;
}

bool isSmallWidth(
  final BoxConstraints constraints, {
  final num minWidth = Constants.narrowScreenWidthThreshold,
}) {
  if (constraints.maxWidth < minWidth) {
    return true;
  }
  return false;
}

num numValueOrDefault(final num? value, {final num defaultValueIfNull = 0}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

double roundDouble(final double value, final int places) {
  final num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

/// Rounds a given value to the specified number of decimal places.
///
/// @param value The value to be rounded.
/// @param places The number of decimal places to round to.
/// @return The rounded value.
/// @throws ArgumentError If the number of decimal places is negative.
///
double roundToDecimalPlaces(double value, int places) {
  if (places < 0) {
    throw ArgumentError('Decimal places must be non-negative');
  }
  int factor = pow(10, places).toInt();
  return (value * factor).round() / factor;
}

/// Round up to next divisor level
int roundToNextNaturalFit(final int number, final int divisor) {
  if (number % divisor == 0) {
    // already at the nature next fit
    return number;
  }
  // Calculate the remainder when dividing the number by the divisor.
  final int remainder = number % divisor;
  final int base = number - remainder;
  return base + divisor;
}

/// Next rounded upper value
/// 1912 > 2000
/// 777 > 1000
/// 34 > 100
/// 5 > 10
int roundToTheNextNaturalFit(final int value) {
  if (value > 1000000) {
    return roundToNextNaturalFit(value, 1000000);
  }

  if (value > 100000) {
    return roundToNextNaturalFit(value, 100000);
  }

  if (value > 10000) {
    return roundToNextNaturalFit(value, 10000);
  }

  if (value > 1000) {
    return roundToNextNaturalFit(value, 1000);
  }

  if (value > 100) {
    return roundToNextNaturalFit(value, 100);
  }

  if (value > 50) {
    return roundToNextNaturalFit(value, 50);
  }

  if (value > 10) {
    return roundToNextNaturalFit(value, 10);
  }
  return 10;
}

void showSnackBar(final BuildContext context, final String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ),
  );
}

String stringValueOrDefault(
  final String? value, {
  final String defaultValueIfNull = '',
}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

double trimToFiveDecimalPlaces(double value) {
  // Multiply the value by 100,000 to move the decimal point 5 places to the right
  double multipliedValue = value * 100000;
  // Round the result to the nearest integer
  double roundedValue = multipliedValue.roundToDouble();
  // Divide the rounded value by 100,000 to move the decimal point back to its original position
  return roundedValue / 100000;
}

class Debouncer {
  Debouncer([this.duration = const Duration(seconds: 1)]);

  final Duration duration;

  Timer? _timer;

  void run(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }
}

class TimeLapse {
  TimeLapse() {
    stopwatch = Stopwatch()..start();
  }

  Stopwatch? stopwatch;

  // End stopwatch and print time spent
  void endAndPrint() {
    // print('Elapsed time: ${stopwatch?.elapsedMilliseconds} milliseconds');
  }
}

extension Range on num {
  bool isBetween(final num from, final num to) {
    return from < this && this < to;
  }

  bool isBetweenOrEqual(final num from, final num to) {
    return from < this && this < to;
  }
}

bool isConsideredZero(num value, [double epsilon = 0.009]) {
  return value.abs() <= epsilon;
}

Future<void> launchGoogleSearch(String query) async {
  final Uri url = Uri.parse('https://www.google.com/search?q=$query');
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
