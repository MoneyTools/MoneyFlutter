import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

numValueOrDefault(num? value, {num defaultValueIfNull = 0}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

intValueOrDefault(int? value, {int defaultValueIfNull = 0}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

boolValueOrDefault(bool? value, {bool defaultValueIfNull = false}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

bool isSmallWidth(BoxConstraints constraints, {num minWidth = Constants.narrowScreenWidthThreshold}) {
  if (constraints.maxWidth < minWidth) {
    return true;
  }
  return false;
}

ThemeData getTheme(BuildContext context) {
  return Theme.of(context);
}

TextTheme getTextTheme(BuildContext context) {
  return getTheme(context).textTheme;
}

ColorScheme getColorTheme(BuildContext context) {
  return getTheme(context).colorScheme;
}

double roundDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

String getCurrencyText(double value) {
  final formatCurrency = NumberFormat("#,##0.00", "en_US");
  return formatCurrency.format(value);
}

String getDateAsText(date) {
  return date.toIso8601String().split('T').first;
}

int sortByStringIgnoreCase(textA, textB) {
  return textA.toUpperCase().compareTo(textB.toUpperCase());
}

int sortByString(a, b, ascending) {
  if (ascending) {
    return sortByStringIgnoreCase(a, b);
  } else {
    return sortByStringIgnoreCase(b, a);
  }
}

int sortByValue(double a, double b, ascending) {
  if (ascending) {
    return (b - a).toInt();
  } else {
    return (a - b).toInt();
  }
}

extension Range on num {
  bool isBetween(num from, num to) {
    return from < this && this < to;
  }

  bool isBetweenOrEqual(num from, num to) {
    return from < this && this < to;
  }
}

extension Range2 on double {
  bool isBetween(num from, num to) {
    return from < this && this < to;
  }

  bool isBetweenOrEqual(num from, num to) {
    return from < this && this < to;
  }
}

Color invertColor(Color color) {
  final r = 255 - color.red;
  final g = 255 - color.green;
  final b = 255 - color.blue;

  return Color.fromARGB((color.opacity * 255).round(), r, g, b);
}
