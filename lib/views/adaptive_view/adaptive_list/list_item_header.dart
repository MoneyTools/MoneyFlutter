import 'package:flutter/material.dart';
import 'package:money/models/fields/field_filter.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/widgets/columns/column_header_button.dart';

/// A Row for a Table view
class MyListItemHeader<T> extends StatelessWidget {
  final Color backgoundColor;
  final FieldDefinitions columns;
  final FieldFilters filterOn;
  final int sortByColumn;
  final bool sortAscending;
  final bool itemsAreAllSelected;
  final Function(bool)? onSelectAll;
  final Function(int columnIndex) onTap;
  final Function(Field<dynamic>)? onLongPress;

  const MyListItemHeader({
    super.key,
    this.backgoundColor = Colors.transparent,
    required this.columns,
    required this.filterOn,
    required this.sortByColumn,
    required this.sortAscending,
    this.itemsAreAllSelected = false,
    this.onSelectAll,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(final BuildContext context) {
    final List<Widget> headers = <Widget>[];
    if (onSelectAll != null) {
      headers.add(
        Checkbox(
          value: itemsAreAllSelected,
          onChanged: (bool? selected) {
            onSelectAll!(selected == true);
          },
        ),
      );
    }
    for (int i = 0; i < columns.length; i++) {
      final Field<dynamic> columnDefinition = columns[i];
      headers.add(
        buildColumnHeaderButton(
          context,
          columnDefinition.name,
          columnDefinition.align,
          columnDefinition.columnWidth.index,
          getSortIndicator(sortByColumn, i, sortAscending),
          filterOn.list.firstWhereOrNull((item) => item.fieldName == columnDefinition.name) != null,
          // Press
          () {
            onTap(i);
          },
          // Long Press
          () {
            onLongPress?.call(columnDefinition);
          },
        ),
      );
    }
    return Container(
      color: backgoundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(children: headers),
    );
  }
}
