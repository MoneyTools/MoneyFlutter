import 'package:flutter/foundation.dart';

class ViewHeaderMultipleSelection {
  final VoidCallback? onToggleMode;
  final bool isMultiSelectionOn;
  final ValueNotifier<List<int>> selectedItems;

  ViewHeaderMultipleSelection({
    required this.onToggleMode,
    required this.isMultiSelectionOn,
    required this.selectedItems,
  });
}
