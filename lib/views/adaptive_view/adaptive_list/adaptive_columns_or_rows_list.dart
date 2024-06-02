import 'package:flutter/material.dart';
import 'package:money/views/adaptive_view/adaptive_list/list_view.dart';

class AdaptiveListColumnsOrRows extends StatelessWidget {
  const AdaptiveListColumnsOrRows({
    super.key,
    required this.list,
    required this.fieldDefinitions,
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
  });

  final List<MoneyObject> list;
  final FieldDefinitions fieldDefinitions;
  final int sortByFieldIndex;
  final bool sortAscending;

  // Selections
  final ValueNotifier<List<int>> selectedItemsByUniqueId;
  final bool isMultiSelectionOn;
  final Function? onSelectionChanged;
  final Function? onContextMenu;

  // Display as Card vs Columns
  final bool displayAsColumns;
  final Function(int columnHeaderIndex)? onColumnHeaderTap;
  final Function(Field field)? onColumnHeaderLongPress;
  final Function(BuildContext p1, int p2)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (displayAsColumns)
          MyListItemHeader<MoneyObject>(
            columns: fieldDefinitions,
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
                    onSelectionChanged?.call();
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
          ),
        ),
      ],
    );
  }
}
