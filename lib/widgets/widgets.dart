import 'package:flutter/foundation.dart';

// Exports
export 'package:money/widgets/center_message.dart';
export 'package:money/widgets/chart.dart';
export 'package:money/widgets/circle.dart';
export 'package:money/widgets/confirmation_dialog.dart';
export 'package:money/widgets/dialog/dialog.dart';
export 'package:money/widgets/filter_input.dart';
export 'package:money/widgets/three_part_label.dart';

bool isMobile() {
  return defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android;
}
