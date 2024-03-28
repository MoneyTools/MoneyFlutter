import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/fields/fields.dart';

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
      final Field<T, dynamic> columnDefinition = columns.definitions[i];
      headers.add(
        widgetHeaderButton(
          context,
          columnDefinition.name,
          columnDefinition.align,
          columnDefinition.columnWidth.index,
          getSortIndicated(i),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(children: headers),
    );
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
  final int flex,
  final SortIndicator sortIndicator,
  final VoidCallback? onClick,
  final VoidCallback? onLongPress,
) {
  final Widget? icon = buildSortIconNameWidget(sortIndicator);

  return Expanded(
    flex: flex,
    child: Tooltip(
      message: ('$text\n${getSortingTooltipText(sortIndicator)}').trim(),
      child: TextButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<OutlinedBorder>(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Remove rounded corners
            ),
          ),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
        ),
        onPressed: onClick,
        onLongPress: onLongPress,
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            if (textAlign == TextAlign.right || textAlign == TextAlign.center) const Spacer(),
            Text(
              text,
              softWrap: false,
              textAlign: textAlign,
              overflow: TextOverflow.fade,
              style: getTextTheme(context).labelSmall!.copyWith(color: getColorTheme(context).secondary),
            ),
            if (icon != null) icon,
            if (textAlign == TextAlign.left || textAlign == TextAlign.center) const Spacer(),
          ],
        ),
      ),
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

String getSortingTooltipText(final SortIndicator sortIndicator) {
  switch (sortIndicator) {
    case SortIndicator.sortAscending:
      return 'Ascending';
    case SortIndicator.sortDescending:
      return 'Descending';
    case SortIndicator.none:
    default:
      return '';
  }
}

enum SortIndicator {
  none,
  sortAscending,
  sortDescending,
}
