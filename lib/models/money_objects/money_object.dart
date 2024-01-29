// Exports
import 'package:flutter/material.dart';
import 'package:money/helpers/json_helper.dart';
import 'package:money/models/fields/fields.dart';

export 'dart:ui';
export 'package:money/helpers/misc_helpers.dart';
export 'package:money/models/fields/field.dart';

class MoneyObject<C> {
  /// All object must have a unique identified
  int get uniqueId => -1;

  MoneyObject<C> fromJson(final MyJson row) {
    return MoneyObject<C>();
  }

  ///
  /// Column 1 | Column 2 | Column 3
  ///
  Widget Function(Fields<C>, C)? buildListWidgetForLargeScreen = (final Fields<C> fields, final C instance) {
    return fields.getRowOfColumns(instance);
  };

  ///
  /// Title       |
  /// ------------+ Right
  /// SubTitle    |
  ///
  Widget Function()? buildListWidgetForSmallScreen = () => const Text('Small screen content goes here');
}
