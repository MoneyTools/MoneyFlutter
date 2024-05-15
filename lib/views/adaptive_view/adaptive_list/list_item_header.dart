import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/fields/fields.dart';

/// A Row for a Table view
class MyListItemHeader<T> extends StatelessWidget {
  final FieldDefinitions columns;
  final int sortByColumn;
  final bool sortAscending;
  final bool itemsAreAllSelected;
  final Function(bool)? onSelectAll;
  final Function(int columnIndex) onTap;
  final Function(Field<dynamic>)? onLongPress;

  const MyListItemHeader({
    super.key,
    required this.columns,
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
  final Widget? orderIndicator = buildSortIconNameWidget(sortIndicator);

  return Expanded(
    flex: flex,
    child: Tooltip(
      message: ('$text\n${getSortingTooltipText(sortIndicator)}').trim(),
      child: TextButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<OutlinedBorder>(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Remove rounded corners
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: 3.0, // Left and right padding
            ),
          ),
        ),
        onPressed: onClick,
        onLongPress: onLongPress,
        // clipBehavior: Clip.hardEdge,
        child: _buildTextAndSortOrder(context, textAlign, text, orderIndicator),
      ),
    ),
  );
}

Widget _buildTextAndSortOrder(
  BuildContext context,
  TextAlign align,
  final String text,
  final Widget? orderIndicator,
) {
  switch (align) {
    case TextAlign.center:
      return HeaderContentCenter(text: text, trailingWidget: orderIndicator);

    case TextAlign.right:
    case TextAlign.end:
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              text,
              softWrap: false,
              textAlign: TextAlign.right,
              overflow: TextOverflow.clip,
              style: getTextTheme(context).labelSmall!.copyWith(color: getColorTheme(context).secondary),
            ),
          ),
          if (orderIndicator != null) orderIndicator,
        ],
      );

    case TextAlign.left:
    case TextAlign.start:
    default:
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            text,
            softWrap: false,
            textAlign: TextAlign.left,
            overflow: TextOverflow.clip,
            style: getTextTheme(context).labelSmall!.copyWith(color: getColorTheme(context).secondary),
          ),
          if (orderIndicator != null) orderIndicator,
        ],
      );
  }
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

class HeaderContentCenter extends StatelessWidget {
  final String text;
  final Widget? trailingWidget;

  const HeaderContentCenter({super.key, required this.text, required this.trailingWidget});

  @override
  Widget build(BuildContext context) {
    final Widget textWidget = Text(
      text,
      softWrap: false,
      textAlign: TextAlign.center,
      overflow: TextOverflow.clip,
      style: getTextTheme(context).labelSmall!.copyWith(color: getColorTheme(context).secondary),
    );

    if (trailingWidget == null) {
      return textWidget;
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Flexible(child: textWidget), trailingWidget!]);
  }
}
