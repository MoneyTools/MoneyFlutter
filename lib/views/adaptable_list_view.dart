import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/widgets/list_view/list_view.dart';

class AdaptableListView extends StatelessWidget {
  final Widget? top;
  final FieldDefinitions fieldDefinitions;
  final List<MoneyObject> list;
  final Widget? bottom;
  final int flexBottom;
  final int sortByFieldIndex;
  final bool sortAscending;
  final bool applySorting;
  final ValueNotifier<List<int>> selectedItemsByUniqueId;
  final Function(BuildContext, int)? onItemTap;
  final Function(int columnHeaderIndex)? onColumnHeaderTap;
  final Function(Field<dynamic> field)? onColumnHeaderLongPress;

  const AdaptableListView({
    super.key,
    this.top,
    required this.fieldDefinitions,
    required this.list,
    required this.selectedItemsByUniqueId,
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
        final bool useColumns = !isSmallWidth(constraints);
        return Column(
          children: <Widget>[
            // Optional upper Title area
            if (top != null) top!,

            if (useColumns)
              MyListItemHeader<MoneyObject>(
                columns: fieldDefinitions,
                sortByColumn: sortByFieldIndex,
                sortAscending: sortAscending,
                onTap: (int index) => onColumnHeaderTap?.call(index),
                onLongPress: (Field<dynamic> field) => onColumnHeaderLongPress?.call(field),
              ),

            // The actual List
            Expanded(
              flex: 1,
              child: MyListView<MoneyObject>(
                list: list,
                selectedItemIds: selectedItemsByUniqueId,
                fields: Fields<MoneyObject>()..setDefinitions(fieldDefinitions),
                asColumnView: useColumns,
                onTap: onItemTap,
                unSelectable: true,
              ),
            ),

            // Optional bottom details panel
            if (bottom != null)
              Expanded(
                  flex: flexBottom,
                  // this will split the vertical view when expanded
                  child: bottom!),
          ],
        );
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
            fieldDefinition.valueFromInstance(a).toString(),
            fieldDefinition.valueFromInstance(b).toString(),
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
