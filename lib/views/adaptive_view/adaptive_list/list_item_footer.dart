import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/widgets/columns/column_footer_button.dart';

/// A Row for a Table view
class MyListItemFooter<T> extends StatelessWidget {
  final FieldDefinitions columns;
  final bool multiSelectionOn;

  final Function(int columnIndex) onTap;
  final Function(Field<dynamic>)? onLongPress;
  final Widget? Function(Field field)? getColumnFooterWidget;

  const MyListItemFooter({
    super.key,
    required this.columns,
    required this.multiSelectionOn,
    required this.onTap,
    this.onLongPress,
    this.getColumnFooterWidget,
  });

  @override
  Widget build(final BuildContext context) {
    final List<Widget> headers = <Widget>[];
    if (multiSelectionOn) {
      headers.add(
        Opacity(
          opacity: 0, // We only want to use the same width as the Header Checkbox
          child: Checkbox(
            value: false,
            onChanged: (bool? _) {},
          ),
        ),
      );
    }
    for (int i = 0; i < columns.length; i++) {
      final Field<dynamic> columnDefinition = columns[i];
      headers.add(
        buildColumnFooterButton(
          context: context, textAlign: columnDefinition.align, flex: columnDefinition.columnWidth.index,
          // Press
          onPressed: () {
            onTap(i);
          },
          // Long Press
          onLongPress: () {
            onLongPress?.call(columnDefinition);
          },
          child: getColumnFooterWidget?.call(columnDefinition),
        ),
      );
    }
    return Container(
      color: getColorTheme(context).surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(children: headers),
    );
  }
}
