import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';

/// A Row for a Table view
class MyTableRow extends StatefulWidget {
  final KeyEventResult Function(FocusNode, RawKeyEvent) onListViewKeyEvent;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final bool isSelected;
  final bool autoFocus;
  final List<Widget> children;

  const MyTableRow({
    super.key,
    required this.onListViewKeyEvent,
    required this.isSelected,
    this.autoFocus = false,
    this.onTap,
    this.onDoubleTap,
    required this.children,
  });

  @override
  State<MyTableRow> createState() => MyTableRowState();
}

class MyTableRowState extends State<MyTableRow> {
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
  }

  @override
  void didUpdateWidget(final MyTableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    isSelected = widget.isSelected;
  }

  @override
  Widget build(final BuildContext context) {
    final Color backgroundColor = isSelected ? getColorTheme(context).inversePrimary : Colors.transparent;

    return Focus(
        autofocus: widget.autoFocus,
        onFocusChange: (final bool value) {
          // debugLog('focus lost $value index $currentIndex');
          if (value) {}
        },
        onKey: widget.onListViewKeyEvent,
        child: GestureDetector(
          onTap: () {
            setState(() {
              isSelected = true;
            });
            widget.onTap?.call();
          },
          onDoubleTap: widget.onDoubleTap,
          child: Container(
            color: backgroundColor,
            child: Row(children: widget.children),
          ),
        ));
  }
}
