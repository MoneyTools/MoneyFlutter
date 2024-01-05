import 'dart:math';
import 'package:flutter/material.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/constants.dart';
import 'package:flutter/foundation.dart';

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

bool isSmallWidth(
  final BoxConstraints constraints, {
  final num minWidth = Constants.narrowScreenWidthThreshold,
}) {
  if (constraints.maxWidth < minWidth) {
    return true;
  }
  return false;
}

double roundDouble(final double value, final int places) {
  final num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

int sortByString(final dynamic a, final dynamic b, final bool ascending) {
  if (ascending) {
    return stringCompareIgnoreCasing1(a as String, b as String);
  } else {
    return stringCompareIgnoreCasing1(b as String, a as String);
  }
}

int sortByValue(final num a, final num b, final bool ascending) {
  if (ascending) {
    return (b - a).toInt();
  } else {
    return (a - b).toInt();
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

void debugLog(final String message) {
  if (kDebugMode) {
    print(message);
  }
}

Widget getViewExpandAndPadding(final Widget child) {
  return Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(8, 0, 8, 0), child: child));
}

/// Return the first element of type T in a list given a list of possible index;
T? getFirstElement<T>(final List<int> indices, final List<dynamic> list) {
  if (indices.isNotEmpty) {
    final int index = indices.first;
    return list[index] as T?;
  }
  return null;
}

/// Next rounded upper value
/// 1912 > 2000
/// 777 > 1000
/// 34 > 100
/// 5 > 10
int roundToTheNextNaturalFit(final int value) {
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