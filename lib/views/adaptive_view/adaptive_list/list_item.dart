import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';

/// A Row for a Table view
class MyListItem extends StatefulWidget {
  final KeyEventResult Function(FocusNode, KeyEvent) onListViewKeyEvent;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureTapCallback? onLongPress;
  final bool isSelected;
  final bool autoFocus;
  final Widget child;
  final Color adornmentColor;

  const MyListItem({
    super.key,
    required this.onListViewKeyEvent,
    required this.isSelected,
    this.autoFocus = false,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.adornmentColor = Colors.transparent,
    required this.child,
  });

  @override
  State<MyListItem> createState() => MyListItemState();
}

class MyListItemState extends State<MyListItem> {
  bool isSelected = false;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
  }

  @override
  void didUpdateWidget(final MyListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    isSelected = widget.isSelected;
  }

  @override
  Widget build(final BuildContext context) {
    final Color backgroundColor = isSelected
        ? getColorTheme(context).inversePrimary
        : _hovering
            ? getColorTheme(context).inversePrimary.withOpacity(0.5)
            : Colors.transparent;

    return Focus(
      autofocus: widget.autoFocus,
      onFocusChange: (final bool value) {
        // debugLog('focus lost $value index $currentIndex');
        if (value) {}
      },
      onKeyEvent: widget.onListViewKeyEvent,
      child: MouseRegion(
        onHover: (event) => setState(() => _hovering = true),
        onExit: (event) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: () {
            setState(() {
              isSelected = !isSelected;
            });
            widget.onTap?.call();
          },
          onDoubleTap: widget.onDoubleTap,
          onLongPress: widget.onLongPress,
          child: Container(
            // height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                top: BorderSide(width: 0.5, color: getColorTheme(context).outline.withOpacity(0.3)),
                left: BorderSide(width: 2, color: widget.adornmentColor),
                bottom: BorderSide(width: 0.5, color: getColorTheme(context).outline.withOpacity(0.3)),
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
