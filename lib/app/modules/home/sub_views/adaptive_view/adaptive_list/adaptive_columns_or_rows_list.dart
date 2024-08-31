import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/widgets/widgets.dart';
import 'package:money/app/data/models/fields/field_filter.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_item_footer.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_view.dart';

export 'package:flutter/material.dart';

class AdaptiveListColumnsOrRows extends StatelessWidget {
  const AdaptiveListColumnsOrRows({
    super.key,
    required this.list,
    required this.fieldDefinitions,
    required this.filters,
    required this.selectedItemsByUniqueId,
    required this.displayAsColumns,
    this.sortByFieldIndex = 0,
    this.sortAscending = true,
    this.isMultiSelectionOn = false,
    this.onSelectionChanged,
    this.onContextMenu,
    this.onColumnHeaderTap,
    this.onColumnHeaderLongPress,
    this.onItemTap,
    this.onItemLongPress,
    this.getColumnFooterWidget,
    this.backgroundColorForHeaderFooter,
  });

  final Widget? Function(Field field)? getColumnFooterWidget;
  final Function(int uniqueId)? onSelectionChanged;
  final Function(int columnHeaderIndex)? onColumnHeaderTap;
  final Function(Field field)? onColumnHeaderLongPress;
  final Function(BuildContext context, int itemId)? onItemTap;
  final Function(BuildContext context, int itemId)? onItemLongPress;
  final Color? backgroundColorForHeaderFooter;
  final FieldDefinitions fieldDefinitions;
  final FieldFilters filters;
  final bool isMultiSelectionOn;
  final List<MoneyObject> list;
  final Function? onContextMenu;
  final bool sortAscending;
  final int sortByFieldIndex;

  // Display as Card vs Columns
  final bool displayAsColumns;

  // Selections
  final ValueNotifier<List<int>> selectedItemsByUniqueId;

  @override
  Widget build(BuildContext context) {
    final theContent = Column(
      children: <Widget>[
        // Header
        if (displayAsColumns)
          MyListItemHeader<MoneyObject>(
            backgroundColor: backgroundColorForHeaderFooter ?? getColorTheme(context).surfaceContainerLow,
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
            fields: fieldDefinitions,
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
            backgroundColor: backgroundColorForHeaderFooter ?? getColorTheme(context).surfaceContainerLow,
            columns: fieldDefinitions,
            multiSelectionOn: isMultiSelectionOn,
            getColumnFooterWidget: getColumnFooterWidget!,
            onTap: (int index) => () {},
            onLongPress: (Field<dynamic> field) => () {},
          ),
      ],
    );

    if (displayAsColumns && !context.isWidthLarge) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 1500,
          child: theContent,
        ),
      );
    } else {
      return theContent;
    }
  }
}
