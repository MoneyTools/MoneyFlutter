import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:money/models/constants.dart';
import 'package:flutter/foundation.dart';

String stringValueOrDefault(final String? value, {final String defaultValueIfNull = ''}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

num numValueOrDefault(final num? value, {final num defaultValueIfNull = 0}) {
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

double doubleValueOrDefault(final double? value, {final double defaultValueIfNull = 0}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

bool boolValueOrDefault(final bool? value, {final bool defaultValueIfNull = false}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

DateTime dateValueOrDefault(final DateTime? value, {final DateTime? defaultValueIfNull}) {
  if (value == null) {
    return defaultValueIfNull ?? DateTime.now();
  }
  return value;
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

bool isSmallDevice(final BuildContext context) {
  // Get the screen size
  final screenSize = MediaQuery.of(context).size;

  // Determine if the screen width is smaller than a certain threshold
  return screenSize.width < 600;
}

double roundDouble(final double value, final int places) {
  final num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

extension Range on num {
  bool isBetween(final num from, final num to) {
    return from < this && this < to;
  }

  bool isBetweenOrEqual(final num from, final num to) {
    return from < this && this < to;
  }
}

void debugLog(final String message) {
  if (kDebugMode) {
    print(message);
  }
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

class TimeLapse {
  Stopwatch? stopwatch;

  TimeLapse() {
    stopwatch = Stopwatch()..start();
  }

  // End stopwatch and print time spent
  void endAndPrint() {
    // print('Elapsed time: ${stopwatch?.elapsedMilliseconds} milliseconds');
  }
}

bool isBetween(final num value, final num min, final num max) {
  return value > min && value < max;
}

bool isBetweenOrEqual(final num value, final num min, final num max) {
  return value >= min && value <= max;
}

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

bool isPlatformMobile() {
  return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}
