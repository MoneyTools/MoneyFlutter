import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';

/// A Row for a Table view
class MyListItemAsColumn extends StatefulWidget {
  final KeyEventResult Function(FocusNode, RawKeyEvent) onListViewKeyEvent;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final bool isSelected;
  final bool autoFocus;
  final bool asColumnView;
  final Widget child;

  const MyListItemAsColumn({
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
  State<MyListItemAsColumn> createState() => MyListItemAsColumnState();
}

class MyListItemAsColumnState extends State<MyListItemAsColumn> {
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
  }

  @override
  void didUpdateWidget(final MyListItemAsColumn oldWidget) {
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
            child: widget.child,
          ),
        ));
  }
}
