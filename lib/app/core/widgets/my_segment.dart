import 'package:flutter/material.dart';
import 'package:money/app/controller/theme_controller.dart';

SegmentedButton<int> mySegmentSelector({
  required List<ButtonSegment<int>> segments,
  required final int selectedId,

  /// returns the new selected segment ID
  required Function(int) onSelectionChanged,
}) {
  return SegmentedButton<int>(
    style: const ButtonStyle(
      visualDensity: VisualDensity(horizontal: -4, vertical: -4),
    ),

    // only show the checkMark for larger devices
    showSelectedIcon: ThemeController.to.isDeviceWidthLarge.value,
    segments: segments,
    selected: <int>{selectedId},
    onSelectionChanged: (final Set<int> newSelection) {
      onSelectionChanged(newSelection.first);
    },
  );
}
