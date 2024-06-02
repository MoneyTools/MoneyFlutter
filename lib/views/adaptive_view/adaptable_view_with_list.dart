import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/views/adaptive_view/adaptive_list/adaptive_columns_or_rows_list.dart';
import 'package:money/views/adaptive_view/adaptive_list/list_view.dart';

class AdaptiveViewWithList extends StatelessWidget {
  final Widget? top;
  final FieldDefinitions fieldDefinitions;
  final List<MoneyObject> list;
  final Widget? bottom;
  final int flexBottom;
  final int sortByFieldIndex;
  final bool sortAscending;
  final bool applySorting;

  // Selection
  final ValueNotifier<List<int>> selectedItemsByUniqueId;
  final Function onSelectionChanged;
  final bool isMultiSelectionOn;

  final Function(BuildContext, int)? onItemTap;
  final Function(int columnHeaderIndex)? onColumnHeaderTap;
  final Function(Field<dynamic> field)? onColumnHeaderLongPress;

  const AdaptiveViewWithList({
    super.key,
    this.top,
    required this.fieldDefinitions,
    required this.list,
    required this.selectedItemsByUniqueId,
    required this.onSelectionChanged,
    required this.isMultiSelectionOn,
    this.bottom,
    this.flexBottom = 1,
    this.sortByFieldIndex = 0,
    this.sortAscending = true,
    this.applySorting = true,
    this.onItemTap,
    this.onColumnHeaderTap,
    this.onColumnHeaderLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (applySorting) {
      sortList();
    }
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        final bool displayAsColumns = !isSmallWidth(constraints);
        return ValueListenableBuilder<List<int>>(
            valueListenable: selectedItemsByUniqueId,
            builder: (final BuildContext context, final List<int> listOfSelectedItemIndex, final _) {
              return Column(
                children: [
                  // Top - Title area
                  if (top != null) top!,

                  // Middle
                  Expanded(
                    child: AdaptiveListColumnsOrRows(
                      // List of Money Object instances
                      list: list,
                      fieldDefinitions: fieldDefinitions,
                      sortByFieldIndex: sortByFieldIndex,
                      sortAscending: sortAscending,

                      // Display as Cards or Columns
                      // On small device you can display rows a Cards instead of Columns
                      displayAsColumns: displayAsColumns,
                      onColumnHeaderTap: onColumnHeaderTap,
                      onColumnHeaderLongPress: onColumnHeaderLongPress,

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
            });
      },
    );
  }

  void sortList() {
    if (isIndexInRange(fieldDefinitions, sortByFieldIndex)) {
      final Field<dynamic> fieldDefinition = fieldDefinitions[sortByFieldIndex];
      if (fieldDefinition.sort == null) {
        // No sorting function found, fallback to String sorting
        list.sort((final MoneyObject a, final MoneyObject b) {
          return sortByString(
            fieldDefinition.getValueForDisplay(a).toString(),
            fieldDefinition.getValueForDisplay(b).toString(),
            sortAscending,
          );
        });
      } else {
        list.sort((final MoneyObject a, final MoneyObject b) {
          return fieldDefinition.sort!(a, b, sortAscending);
        });
      }
    }
  }
}
