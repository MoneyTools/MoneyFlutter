import 'package:flutter/foundation.dart';

class ViewHeaderMultipleSelection {
  ViewHeaderMultipleSelection({
    required this.onToggleMode,
    required this.isMultiSelectionOn,
    required this.selectedItems,
  });
  final VoidCallback? onToggleMode;
  final bool isMultiSelectionOn;
  final ValueNotifier<List<int>> selectedItems;
}
