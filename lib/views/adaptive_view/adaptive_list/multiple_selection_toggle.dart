import 'package:flutter/material.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/views/adaptive_view/adaptive_list/multiple_selection_context.dart';

class MultipleSelectionToggle extends StatelessWidget {
  const MultipleSelectionToggle({
    super.key,
    required this.multipleSelection,
  });

  final ViewHeaderMultipleSelection? multipleSelection;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<int>>(
      valueListenable: multipleSelection!.selectedItems,
      builder: (final BuildContext context, final List<int> listOfSelectedItemIndex, final _) {
        return Tooltip(
          message: 'Toggle multi-selection',
          child: IntrinsicWidth(
            child: Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.checklist),
                    isSelected: multipleSelection!.isMultiSelectionOn,
                    onPressed: () {
                      multipleSelection!.onToggleMode!();
                    }),
                if (multipleSelection!.isMultiSelectionOn)
                  Text(getIntAsText(multipleSelection!.selectedItems.value.length)),
              ],
            ),
          ),
        );
      },
    );
  }
}
