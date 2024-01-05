import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/widgets/columns.dart';
import 'package:money/widgets/widget_view.dart';

enum SortIndicator { none, sortAscending, sortDescending }

/// A Row for a Table view
class MyTableHeader<T> extends StatelessWidget {
  final ColumnDefinitions<T> columns;
  final int sortByColumn;
  final bool sortAscending;
  final Function onTap;
  final Function onLongPress;

  const MyTableHeader({
    super.key,
    required this.columns,
    required this.sortByColumn,
    required this.sortAscending,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(final BuildContext context) {
    final List<Widget> headers = <Widget>[];
    for (int i = 0; i < columns.list.length; i++) {
      headers.add(
        widgetHeaderButton(
          context,
          columns.list[i].name,
          columns.list[i].align,
          getSortIndicated(i),
          // Press
          () {
            onTap(i);
          },
          // Long Press
          () {
            onLongPress(i);
          },
        ),
      );
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
