import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/settings.dart';
import 'package:money/views/adaptive_view/adaptive_list/multiple_selection_context.dart';
import 'package:money/views/adaptive_view/adaptive_list/multiple_selection_toggle.dart';
import 'package:money/widgets/filter_input.dart';
import 'package:money/widgets/three_part_label.dart';

class ViewHeader extends StatelessWidget {
  final String title;
  final num itemCount;
  final ValueNotifier<List<int>> selectedItems;
  final String description;

  // Optional, used for multi-selection UX
  final ViewHeaderMultipleSelection? multipleSelection;

  final void Function(String)? onFilterChanged;
  final VoidCallback? onAddNewEntry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  final Widget? child;

  const ViewHeader({
    super.key,
    required this.title,
    required this.itemCount,
    required this.selectedItems,
    required this.description,

    // optionals
    this.multipleSelection,
    this.onFilterChanged,
    this.onAddNewEntry,
    this.onEdit,
    this.onDelete,
    this.child,
  });

  @override
  Widget build(final BuildContext context) {
    return ValueListenableBuilder<List<int>>(
      valueListenable: selectedItems,
      builder: (final BuildContext context, final List<int> listOfSelectedItemIndex, final _ /*widget*/) {
        return buildViewHeaderContainer(
          context,
          Settings().isSmallScreen ? _buildSmall(context) : _buildLarge(context),
        );
      },
    );
  }

  static buildViewHeaderContainer(final BuildContext context, final Widget child) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: getColorTheme(context).surfaceContainerHighest,
          border: Border.all(color: getColorTheme(context).outline),
          // borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: child);
  }

  Widget _buildLarge(final BuildContext context) {
    final List<Widget> widgets = [];

    widgets.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IntrinsicWidth(
              child: Row(
            children: [
              ThreePartLabel(text1: title, text2: getIntAsText(itemCount.toInt())),
              // Add
              if (onAddNewEntry != null)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: onAddNewEntry,
                ),
            ],
          )),
          IntrinsicWidth(
              child: Text(description,
                  style: getTextTheme(context).bodySmall!.copyWith(color: getColorTheme(context).onSurfaceVariant))),
        ],
      ),
    );

    if (multipleSelection != null || (selectedItems.value.isNotEmpty && (onEdit != null || onDelete != null))) {
      widgets.add(
        IntrinsicWidth(
          child: Row(
            children: [
              // Multiple-Selection
              if (multipleSelection != null)
                MultipleSelectionToggle(
                  multipleSelection: multipleSelection,
                ),

              // Edit
              if (onEdit != null && selectedItems.value.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                  tooltip: 'Edit selected item(s)',
                ),

              // Delete
              if (onDelete != null && selectedItems.value.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                  tooltip: 'Delete selected item(s)',
                ),
            ],
          ),
        ),
      );
    }

    if (child != null) {
      widgets.add(child!);
    }

    if (onFilterChanged != null) {
      widgets.add(
        SizedBox(
          width: 200,
          child: FilterInput(
              hintText: 'Filter',
              onChanged: (final String text) {
                onFilterChanged!(text);
              }),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 10.0, // Adjust spacing between child elements
            runSpacing: 10.0,
            alignment: WrapAlignment.spaceBetween,
            children: widgets,
          ),
        ),
      ],
    );
  }

  Widget _buildSmall(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: ThreePartLabel(text1: title, text2: getIntAsText(itemCount.toInt())),
            ),
          ),
        ],
      ),
    );
  }
}
