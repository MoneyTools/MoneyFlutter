import 'package:money/core/controller/list_controller.dart';
import 'package:money/core/widgets/widgets.dart';
import 'package:money/data/models/fields/field_filters.dart';
import 'package:money/data/models/money_objects/money_objects.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/adaptive_columns_or_rows_list.dart';

export 'package:flutter/material.dart';

class AdaptiveViewWithList extends StatelessWidget {
  const AdaptiveViewWithList({
    required this.list,
    required this.fieldDefinitions,
    required this.filters,
    required this.selectedItemsByUniqueId,
    required this.onSelectionChanged,
    required this.isMultiSelectionOn,
    required this.listController,
    super.key,
    this.top,
    this.bottom,
    this.flexBottom = 1,
    this.sortByFieldIndex = 0,
    this.sortAscending = true,
    this.applySorting = true,
    this.onItemTap,
    this.onColumnHeaderTap,
    this.onColumnHeaderLongPress,
    this.getColumnFooterWidget,
  });

  final void Function(BuildContext, int)? onItemTap;
  final void Function(int columnHeaderIndex)? onColumnHeaderTap;
  final void Function(Field<dynamic> field)? onColumnHeaderLongPress;
  final Widget? Function(Field<dynamic> field)? getColumnFooterWidget;
  final bool applySorting;
  final Widget? bottom;
  final FieldDefinitions fieldDefinitions;
  final FieldFilters filters;
  final int flexBottom;
  final bool isMultiSelectionOn;
  final List<MoneyObject> list;
  final ListController listController;
  final void Function(int) onSelectionChanged;
  final bool sortAscending;
  final int sortByFieldIndex;
  final Widget? top;

  // Selection
  final ValueNotifier<List<int>> selectedItemsByUniqueId;

  @override
  Widget build(BuildContext context) {
    if (applySorting) {
      MoneyObjects.sortList(
        list,
        fieldDefinitions,
        sortByFieldIndex,
        sortAscending,
      );
    }
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        // display as column for Medium & Large devices
        final bool displayAsColumns = context.isWidthSmall == false;

        return ValueListenableBuilder<List<int>>(
          valueListenable: selectedItemsByUniqueId,
          builder: (
            final BuildContext context,
            final List<int> listOfSelectedItemIndex,
            final _,
          ) {
            return Column(
              children: <Widget>[
                // Top - Title area
                if (top != null) top!,

                // Middle
                Expanded(
                  child: AdaptiveListColumnsOrRows(
                    // List of Money Object instances
                    list: list,
                    fieldDefinitions: fieldDefinitions,
                    filters: filters,
                    sortByFieldIndex: sortByFieldIndex,
                    sortAscending: sortAscending,
                    listController: listController,

                    // Display as Cards or Columns
                    // On small device you can display rows a Cards instead of Columns
                    displayAsColumns: displayAsColumns,
                    onColumnHeaderTap: onColumnHeaderTap,
                    onColumnHeaderLongPress: onColumnHeaderLongPress,
                    getColumnFooterWidget: getColumnFooterWidget,

                    // Selection
                    onItemTap: onItemTap,
                    selectedItemsByUniqueId: selectedItemsByUniqueId,
                    isMultiSelectionOn: isMultiSelectionOn,
                    onSelectionChanged: onSelectionChanged,
                    onContextMenu: () {},
                  ),
                ),

                // Bottom Info panel
                if (bottom != null)
                  Expanded(
                    flex: flexBottom,
                    // this will split the vertical view when expanded
                    child: bottom!,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
