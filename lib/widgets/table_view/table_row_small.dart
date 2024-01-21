import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';

/// A Row for a Table view
class MyTableRowSmall extends StatefulWidget {
  final KeyEventResult Function(FocusNode, RawKeyEvent) onListViewKeyEvent;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final bool isSelected;
  final bool autoFocus;
  final bool asColumnView;
  final Widget child;

  const MyTableRowSmall({
    super.key,
    required this.onListViewKeyEvent,
    required this.isSelected,
    this.autoFocus = false,
    this.asColumnView = true,
    this.onTap,
    this.onDoubleTap,
    required this.child,
  });

  @override
  State<MyTableRowSmall> createState() => MyTableRowSmallState();
}

class MyTableRowSmallState extends State<MyTableRowSmall> {
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
  }

  @override
  void didUpdateWidget(final MyTableRowSmall oldWidget) {
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
            padding: const EdgeInsets.all(4),
            color: backgroundColor,
            child: widget.child,
          ),
        ));
  }
}
