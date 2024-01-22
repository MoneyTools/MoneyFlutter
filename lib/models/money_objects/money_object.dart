// Exports
import 'package:flutter/material.dart';

export 'dart:ui';
export 'package:money/helpers/misc_helpers.dart';
export 'package:money/models/fields/field.dart';

abstract class MoneyObject<C> {
  int get uniqueId;

  ///
  /// Title       |
  /// ------------+ Right
  /// SubTitle    |
  ///
  Widget Function()? buildListWidgetForSmallScreen;
}
