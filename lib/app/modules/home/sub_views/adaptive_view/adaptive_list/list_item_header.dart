import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/columns/column_header_button.dart';
import 'package:money/app/data/models/fields/field_filter.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';

/// A Row for a Table view
class MyListItemHeader<T> extends StatelessWidget {
  const MyListItemHeader({
    required this.columns,
    required this.filterOn,
    required this.sortByColumn,
    required this.sortAscending,
    required this.onTap,
    super.key,
    this.backgoundColor = Colors.transparent,
    this.itemsAreAllSelected = false,
    this.onSelectAll,
    this.onLongPress,
  });

  final Function(bool)? onSelectAll;
  final Function(Field<dynamic>)? onLongPress;
  final Color backgoundColor;
  final FieldDefinitions columns;
  final FieldFilters filterOn;
  final bool itemsAreAllSelected;
  final Function(int columnIndex) onTap;
  final bool sortAscending;
  final int sortByColumn;

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
          context: context,
          text: columnDefinition.name,
          textAlign: columnDefinition.align,
          flex: columnDefinition.columnWidth.index,
          sortIndicator: getSortIndicator(sortByColumn, i, sortAscending),
          hasFilters: filterOn.list.firstWhereOrNull(
                (item) => item.fieldName == columnDefinition.name,
              ) !=
              null,
          onPressed: () {
            onTap(i);
          },
          onLongPress: () {
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
