import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

bool isSmallWidth(BoxConstraints constraints, {num minWidth = Constants.narrowScreenWidthThreshold}) {
  if (constraints.maxWidth < minWidth) {
    return true;
  }
  return false;
}

TextTheme getTextTheme(BuildContext context) {
  var theme = Theme.of(context);
  return theme.textTheme;
}

getColorTheme(BuildContext context) {
  var theme = Theme.of(context);
  return theme.colorScheme;
}

double roundDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

String getCurrencyText(double value) {
  final formatCurrency = NumberFormat("#,##0.00", "en_US");
  return formatCurrency.format(value);
}
