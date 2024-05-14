import 'package:flutter/material.dart';
import 'package:money/views/adaptive_view/adaptive_list/list_view.dart';

class AdaptiveListColumnsOrRows extends StatelessWidget {
  const AdaptiveListColumnsOrRows({
    super.key,
    required this.useColumns,
    required this.fieldDefinitions,
    this.sortByFieldIndex = 0,
    this.sortAscending = true,
    required this.list,
    required this.selectedItemsByUniqueId,
    this.isMultiSelectionOn = false,
    this.onSelectionChanged,
    this.onColumnHeaderTap,
    this.onColumnHeaderLongPress,
    this.onItemTap,
  });

  final bool useColumns;
  final FieldDefinitions fieldDefinitions;
  final int sortByFieldIndex;
  final bool sortAscending;
  final List<MoneyObject> list;
  final ValueNotifier<List<int>> selectedItemsByUniqueId;
  final bool isMultiSelectionOn;
  final Function? onSelectionChanged;
  final Function(int columnHeaderIndex)? onColumnHeaderTap;
  final Function(Field field)? onColumnHeaderLongPress;
  final Function(BuildContext p1, int p2)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (useColumns)
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
            asColumnView: useColumns,
            onTap: onItemTap,
          ),
        ),
      ],
    );
  }
}
