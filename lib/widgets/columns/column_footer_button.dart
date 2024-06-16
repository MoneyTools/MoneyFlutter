import 'package:flutter/material.dart';

Widget buildColumnFooterButton({
  required final BuildContext context,
  required final TextAlign textAlign,
  required final int flex,
  required final VoidCallback? onPressed,
  required final VoidCallback? onLongPress,
  required final Widget? child,
}) {
  return Expanded(
    flex: flex,
    child: Tooltip(
      message: '',
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
        child: _buildTextAndSortAndFilter(context, textAlign, child ?? const SizedBox()),
      ),
    ),
  );
}

Widget _buildTextAndSortAndFilter(
  BuildContext context,
  TextAlign align,
  Widget content,
) {
  MainAxisAlignment rowAlign = MainAxisAlignment.center;

  switch (align) {
    case TextAlign.center:
      rowAlign = MainAxisAlignment.center;

    case TextAlign.right:
    case TextAlign.end:
      rowAlign = MainAxisAlignment.end;

    case TextAlign.left:
    case TextAlign.start:
    default:
      rowAlign = MainAxisAlignment.start;
  }

  return Row(
    mainAxisAlignment: rowAlign,
    children: [content],
  );
}
