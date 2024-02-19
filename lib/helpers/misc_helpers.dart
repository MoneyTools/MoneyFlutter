import 'dart:math';
import 'package:flutter/material.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/constants.dart';
import 'package:flutter/foundation.dart';

String stringValueOrDefault(final String? value, {final String defaultValueIfNull = ''}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

String dateAsIso8601OrDefault(final DateTime? value, {final String defaultValueIfNull = ''}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value.toIso8601String();
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
  final isSmallScreen = screenSize.width < 600;
  return isSmallScreen;
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
    return (a - b).toInt();
  } else {
    return (b - a).toInt();
  }
}

int sortByDate(final DateTime? a, final DateTime? b, [final bool ascending = true]) {
  if (a == null && b == null) {
    return 0;
  }

  if (ascending) {
    if (a == null) {
      return -1;
    }
    if (b == null) {
      return 1;
    }
    return a.compareTo(b);
  } else {
    if (a == null) {
      return 1;
    }
    if (b == null) {
      return -1;
    }
    return b.compareTo(a);
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

List<num> getMinMaxValues(final List<double> list) {
  if (list.isEmpty) {
    return <num>[0, 0];
  }
  if (list.length == 1) {
    return <num>[list[0], list[0]];
  }

  double valueMin = 0.0;
  double valueMax = 0.0;
  if (list[0] < list[1]) {
    valueMin = list[0];
    valueMax = list[1];
  } else {
    valueMin = list[1];
    valueMax = list[0];

    for (double value in list) {
      valueMin = min(valueMin, value);
      valueMax = max(valueMax, value);
    }
  }
  return <num>[valueMin, valueMax];
}
