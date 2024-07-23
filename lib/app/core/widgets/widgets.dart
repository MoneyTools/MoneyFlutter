import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
