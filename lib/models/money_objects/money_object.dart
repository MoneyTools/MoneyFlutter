// Exports
import 'package:flutter/material.dart';
import 'package:money/widgets/table_view/table_row_compact.dart';

export 'dart:ui';
export 'package:money/helpers/misc_helpers.dart';
export 'package:money/models/fields/field.dart';

abstract class MoneyObject<C> {
  int get uniqueId;

  bool get supportSmallList => false;

  ///
  /// Title       |
  /// ------------+ Right
  /// SubTitle    |
  ///
  Widget buildInstanceWidgetSmallScreen() {
    const Widget title = Text('');
    const Widget subTitle = Text('');
    const Widget rightSide = Text('');

    return const TableRowCompact(
      leftTopAsWidget: title,
      leftBottomAsWidget: subTitle,
      rightTopAsWidget: rightSide,
    );
  }
}
