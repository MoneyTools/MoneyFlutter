import 'package:flutter/foundation.dart';

class ViewHeaderMultipleSelection {
  ViewHeaderMultipleSelection({
    required this.onToggleMode,
    required this.isMultiSelectionOn,
    required this.selectedItems,
  });

  final bool isMultiSelectionOn;
  final VoidCallback? onToggleMode;
  final ValueNotifier<List<int>> selectedItems;
}
