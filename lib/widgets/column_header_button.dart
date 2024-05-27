import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';

Widget buildColumnHeaderButton(
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

SortIndicator getSortIndicator(final int currentSort, final int sortToMatch, final bool ascending) {
  if (sortToMatch == currentSort) {
    return ascending ? SortIndicator.sortAscending : SortIndicator.sortDescending;
  }
  return SortIndicator.none;
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
