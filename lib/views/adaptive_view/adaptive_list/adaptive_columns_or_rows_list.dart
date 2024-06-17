import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/fields/field_filter.dart';
import 'package:money/views/adaptive_view/adaptive_list/list_item_footer.dart';
import 'package:money/views/adaptive_view/adaptive_list/list_view.dart';

class AdaptiveListColumnsOrRows extends StatelessWidget {
  const AdaptiveListColumnsOrRows({
    super.key,
    required this.list,
    required this.fieldDefinitions,
    required this.filters,
    this.sortByFieldIndex = 0,
    this.sortAscending = true,
    required this.selectedItemsByUniqueId,
    this.isMultiSelectionOn = false,
    this.onSelectionChanged,
    this.onContextMenu,
    required this.displayAsColumns,
    this.onColumnHeaderTap,
    this.onColumnHeaderLongPress,
    this.onItemTap,
    this.onItemLongPress,
    this.getColumnFooterWidget,
    this.backgoundColorForHeaderFooter,
  });

  final List<MoneyObject> list;
  final FieldDefinitions fieldDefinitions;
  final FieldFilters filters;
  final int sortByFieldIndex;
  final bool sortAscending;
  final Widget? Function(Field field)? getColumnFooterWidget;

  // Selections
  final ValueNotifier<List<int>> selectedItemsByUniqueId;
  final bool isMultiSelectionOn;
  final Function(int uniqueId)? onSelectionChanged;
  final Function? onContextMenu;

  // Display as Card vs Columns
  final bool displayAsColumns;
  final Function(int columnHeaderIndex)? onColumnHeaderTap;
  final Function(Field field)? onColumnHeaderLongPress;
  final Function(BuildContext context, int itemId)? onItemTap;
  final Function(BuildContext context, int itemId)? onItemLongPress;
  final Color? backgoundColorForHeaderFooter;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Header
        if (displayAsColumns)
          MyListItemHeader<MoneyObject>(
            backgoundColor: backgoundColorForHeaderFooter ?? getColorTheme(context).surfaceContainerLow,
            columns: fieldDefinitions,
            filterOn: filters,
            sortByColumn: sortByFieldIndex,
            sortAscending: sortAscending,
            itemsAreAllSelected: list.length == selectedItemsByUniqueId.value.length,
            onSelectAll: isMultiSelectionOn
                ? (bool selectAllRequested) {
                    selectedItemsByUniqueId.value.clear();
                    if (selectAllRequested) {
                      for (final item in list) {
                        selectedItemsByUniqueId.value.add(item.uniqueId);
                      }
                    }
                    onSelectionChanged?.call(-1);
                  }
                : null,
            onTap: (int index) => onColumnHeaderTap?.call(index),
            onLongPress: (Field<dynamic> field) => onColumnHeaderLongPress?.call(field),
          ),

        // The actual List
        Expanded(
          flex: 1,
          child: MyListView<MoneyObject>(
            fields: Fields<MoneyObject>()..setDefinitions(fieldDefinitions),
            list: list,
            selectedItemIds: selectedItemsByUniqueId,
            isMultiSelectionOn: isMultiSelectionOn,
            onSelectionChanged: onSelectionChanged,
            displayAsColumn: displayAsColumns,
            onTap: onItemTap,
            onLongPress: onItemLongPress,
          ),
        ),

        // Footer
        if (displayAsColumns && getColumnFooterWidget != null)
          MyListItemFooter<MoneyObject>(
            backgoundColor: backgoundColorForHeaderFooter ?? getColorTheme(context).surfaceContainerLow,
            columns: fieldDefinitions,
            multiSelectionOn: isMultiSelectionOn,
            getColumnFooterWidget: getColumnFooterWidget,
            onTap: (int index) => () {},
            onLongPress: (Field<dynamic> field) => () {},
          ),
      ],
    );
  }
}
