import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/columns/column_footer_button.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';

/// A Row for a Table view
class MyListItemFooter<T> extends StatelessWidget {
  const MyListItemFooter({
    required this.columns,
    required this.multiSelectionOn,
    required this.onTap,
    super.key,
    this.backgoundColor = Colors.transparent,
    this.onLongPress,
    this.getColumnFooterWidget,
  });

  final Function(Field<dynamic>)? onLongPress;
  final Widget? Function(Field field)? getColumnFooterWidget;
  final Color backgoundColor;
  final FieldDefinitions columns;
  final bool multiSelectionOn;
  final Function(int columnIndex) onTap;

  @override
  Widget build(final BuildContext context) {
    final List<Widget> footerWidgets = <Widget>[];
    if (multiSelectionOn) {
      footerWidgets.add(
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
      footerWidgets.add(
        buildColumnFooterButton(
          context: context,
          textAlign: columnDefinition.align,
          flex: columnDefinition.columnWidth.index,
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
      color: backgoundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(children: footerWidgets),
    );
  }
}
