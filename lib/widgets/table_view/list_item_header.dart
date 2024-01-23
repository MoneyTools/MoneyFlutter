import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/fields/fields.dart';

import 'package:money/views/view.dart';

/// A Row for a Table view
class MyListItemHeader<T> extends StatelessWidget {
  final Fields<T> columns;
  final int sortByColumn;
  final bool sortAscending;
  final Function onTap;
  final Function(Field<T, dynamic>)? onLongPress;

  const MyListItemHeader({
    super.key,
    required this.columns,
    required this.sortByColumn,
    required this.sortAscending,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(final BuildContext context) {
    final List<Widget> headers = <Widget>[];
    for (int i = 0; i < columns.definitions.length; i++) {
      if (columns.definitions[i].useAsColumn) {
        headers.add(
          widgetHeaderButton(
            context,
            columns.definitions[i].name,
            TextAlign.center, // columns.definitions[i].align,
            getSortIndicated(i),
            // Press
            () {
              onTap(i);
            },
            // Long Press
            () {
              final Field<T, dynamic> column = columns.definitions[i];
              onLongPress?.call(column);
            },
          ),
        );
      }
    }
    return Row(children: headers);
  }

  SortIndicator getSortIndicated(final int columnNumber) {
    if (columnNumber == sortByColumn) {
      return sortAscending ? SortIndicator.sortAscending : SortIndicator.sortDescending;
    }
    return SortIndicator.none;
  }
}

Widget widgetHeaderButton(
  final BuildContext context,
  final String text,
  final TextAlign textAlign,
  final SortIndicator sortIndicator,
  final VoidCallback? onClick,
  final VoidCallback? onLongPress,
) {
  final Widget? icon = buildSortIconNameWidget(sortIndicator);
  return Expanded(
    child: TextButton(
      onPressed: onClick,
      onLongPress: onLongPress,
      child: Row(mainAxisAlignment: getRowAlignmentBasedOnTextAlign(textAlign), children: <Widget>[
        Text(text, style: getTextTheme(context).labelSmall!.copyWith(color: Theme.of(context).colorScheme.secondary)),
        if (icon != null) icon,
      ]),
    ),
  );
}

Widget? buildSortIconNameWidget(final SortIndicator sortIndicator) {
  switch (sortIndicator) {
    case SortIndicator.sortAscending:
      return const Icon(Icons.arrow_upward, size: 20.0);
    case SortIndicator.sortDescending:
      return const Icon(Icons.arrow_downward, size: 20.0);
    case SortIndicator.none:
    default:
      return null;
  }
}

enum SortIndicator { none, sortAscending, sortDescending }
