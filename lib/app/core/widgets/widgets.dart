import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:money/app/data/models/constants.dart';

// Exports
export 'package:money/app/core/widgets/center_message.dart';
export 'package:money/app/core/widgets/chart.dart';
export 'package:money/app/core/widgets/circle.dart';
export 'package:money/app/core/widgets/confirmation_dialog.dart';
export 'package:money/app/core/widgets/dialog/dialog.dart';
export 'package:money/app/core/widgets/filter_input.dart';
export 'package:money/app/core/widgets/three_part_label.dart';

bool isMobile() {
  return defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android;
}

/// If the space for rendering the widget is too small this will scale the widget to fit
Widget scaleDown(final Widget child, [AlignmentGeometry alignment = Alignment.center]) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    alignment: alignment,
    child: child,
  );
}

///
///                                       ------
/// Display a border and a question mark | ?    |
///                                       ------
///
Widget widgetUnknown = buildDashboardWidget(const Text('?'));

Widget buildDashboardWidget(final Widget child) {
  return DottedBorder(
    color: Colors.grey.shade600,
    padding: const EdgeInsets.symmetric(horizontal: SizeForPadding.medium),
    radius: const Radius.circular(3),
    child: child,
  );
}

extension ViewExtension on BuildContext {
  bool get isWidthSmall => (MediaQuery.of(this).size.width <= Constants.screenWithSmall);
  bool get isWidthMedium => (MediaQuery.of(this).size.width <= Constants.screenWidthMedium);
  bool get isWidthLarge => (MediaQuery.of(this).size.width > Constants.screenWidthMedium);
}
