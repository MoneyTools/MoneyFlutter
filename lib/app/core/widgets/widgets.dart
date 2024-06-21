import 'package:flutter/foundation.dart';

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
