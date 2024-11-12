import 'package:flutter/material.dart';
import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/widgets/columns/column_content_center.dart';

Widget buildColumnHeaderButton({
  required BuildContext context,
  required String text,
  required TextAlign textAlign,
  required int flex,
  required SortIndicator sortIndicator,
  required bool hasFilters,
  required VoidCallback? onPressed,
  required VoidCallback? onLongPress,
}) {
  return Expanded(
    flex: flex,
    child: Tooltip(
      message: ('$text\n${_getTooltipText(sortIndicator, hasFilters)}').trim(),
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
        onPressed: onPressed,
        onLongPress: onLongPress,
        // clipBehavior: Clip.hardEdge,
        child: _buildTextAndSortAndFilter(
          context,
          textAlign,
          text,
          _buildAdorners(sortIndicator, hasFilters),
        ),
      ),
    ),
  );
}

Widget _buildTextAndSortAndFilter(
  BuildContext context,
  TextAlign align,
  final String text,
  final Widget adorner,
) {
  switch (align) {
    case TextAlign.center:
      return HeaderContentCenter(text: text, trailingWidget: adorner);

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
          adorner,
        ],
      );

    case TextAlign.left:
    case TextAlign.start:
    default:
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              text,
              softWrap: false,
              textAlign: TextAlign.left,
              overflow: TextOverflow.clip,
              style: getTextTheme(context).labelSmall!.copyWith(color: getColorTheme(context).secondary),
            ),
            adorner,
          ],
        ),
      );
  }
}

Widget _buildAdorners(
  final SortIndicator sortIndicator,
  final bool hasFilters,
) {
  return Row(
    children: [
      buildSortIconNameWidget(sortIndicator),
      _buildAdornerFoFilter(hasFilters),
    ],
  );
}

Widget buildSortIconNameWidget(final SortIndicator sortIndicator) {
  switch (sortIndicator) {
    case SortIndicator.sortAscending:
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationX(3.14159), // Rotate 180 degrees on both X and Y axes
        child: const Icon(
          Icons.sort,
          size: 20.0,
        ), // Rotate 180 degrees for descending
      );
    case SortIndicator.sortDescending:
      return const Icon(Icons.sort, size: 20.0);
    case SortIndicator.none:
    default:
      return const SizedBox();
  }
}

Widget _buildAdornerFoFilter(final bool filterOn) {
  if (filterOn) {
    return const Icon(Icons.filter_alt_outlined, size: 20.0);
  }
  return const SizedBox();
}

String _getTooltipText(final SortIndicator sortIndicator, final bool filterOn) {
  String tooltip = filterOn ? 'Filtering\n' : '';

  switch (sortIndicator) {
    case SortIndicator.sortAscending:
      tooltip += 'Sorting Ascending';
    case SortIndicator.sortDescending:
      tooltip += 'Sorting Descending';
    case SortIndicator.none:
    default:
      break;
  }
  return tooltip;
}

enum SortIndicator {
  none,
  sortAscending,
  sortDescending,
}

SortIndicator getSortIndicator(
  final int currentSort,
  final int sortToMatch,
  final bool ascending,
) {
  if (sortToMatch == currentSort) {
    return ascending ? SortIndicator.sortAscending : SortIndicator.sortDescending;
  }
  return SortIndicator.none;
}
