import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/models/money_entity.dart';

import '../helpers.dart';
import 'columns.dart';

class TableWidget extends StatefulWidget {
  final ColumnDefinitions columns;
  final List<MoneyEntity> list;
  final Function onTap;

  const TableWidget({super.key, required this.columns, required this.list, required this.onTap});

  @override
  State<TableWidget> createState() => TableWidgetState();
}

class TableWidgetState extends State<TableWidget> {
  List<int> selectedItems = [0];
  final double itemHeight = 30;
  final scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  FocusScopeNode? _focusScopeNode;

  ColumnDefinitions getColumnDefinitions() {
    return ColumnDefinitions([]);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _focusScopeNode = FocusScope.of(context);

    return RawKeyboardListener(
        autofocus: true,
        onKey: onListViewKeyEvent,
        focusNode: _focusNode,
        child: GestureDetector(
            onTap: () {
              if (_focusScopeNode != null && !_focusNode.hasFocus) {
                _focusScopeNode?.requestFocus(_focusNode);
              }
            },
            child: ListView.builder(
                // physics: const NeverScrollableScrollPhysics(),
                primary: false,
                scrollDirection: Axis.vertical,
                controller: scrollController,
                itemCount: widget.list.length,
                itemExtent: itemHeight,
                // cacheExtent: itemHeight * 1000,
                itemBuilder: (context, index) {
                  return getRow(widget.list, index);
                })));
  }

  onListViewKeyEvent(RawKeyEvent event) {
    if (event.runtimeType == RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          selectedItemOffset(-1);
        });
        return KeyEventResult.handled;
      } else {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          setState(() {
            selectedItemOffset(1);
          });
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.home) {
          setState(() {
            setSelectedItem(0);
          });
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.end) {
          setState(() {
            setSelectedItem(widget.list.length - 1);
          });
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
          setState(() {
            selectedItemOffset(-numberOfItemOnViewPort());
          });
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
          setState(() {
            selectedItemOffset(numberOfItemOnViewPort());
          });
          return KeyEventResult.handled;
        } else {
          // print(event.logicalKey);
        }
      }
    }
    return KeyEventResult.ignored;
  }

  Widget getRow(list, index) {
    List<Widget> cells = getCells(index);

    var backgroundColor = selectedItems.contains(index) ? getColorTheme(context).tertiaryContainer : Colors.transparent;
    return GestureDetector(
      onTap: () {
        if (_focusScopeNode != null && !_focusNode.hasFocus) {
          _focusScopeNode?.requestFocus(_focusNode);
        }
        setState(() {
          selectedItems.clear();
          selectedItems.add(index);
        });
        widget.onTap(context, index);
      },
      child: Container(
        color: backgroundColor,
        child: Row(children: cells),
      ),
    );
  }

  List<Widget> getCells(index) {
    return widget.columns.getCellsForRow(index);
  }

  void selectedItemOffset(int delta) {
    int newPosition = 0;
    if (selectedItems.isNotEmpty) {
      newPosition = selectedItems[0] + delta;
    }

    setSelectedItem(newPosition);
  }

  void setSelectedItem(int newPosition) {
    if (newPosition.isBetween(-1, widget.list.length)) {
      selectedItems.clear();
      selectedItems.add(newPosition);
      scrollToIndex(newPosition);
    }
  }

  void scrollToIndex(int index) {
    var minMax = scrollListenerWithItemCount();

    // print("${minMax[0]} > $index < ${minMax[1]}");

    if (!index.isBetween(minMax[0], minMax[1])) {
      double desiredNewPosition = itemHeight * index;
      scrollController.jumpTo(desiredNewPosition);
    }
  }

  int numberOfItemOnViewPort() {
    double viewportHeight = scrollController.position.viewportDimension;
    int numberOfItemDisplayed = (viewportHeight / itemHeight).ceil();
    return numberOfItemDisplayed;
  }

  // use this if total item count is known
  scrollListenerWithItemCount() {
    int itemCount = widget.list.length;
    double scrollOffset = scrollController.position.pixels;
    double viewportHeight = scrollController.position.viewportDimension;
    double scrollRange = scrollController.position.maxScrollExtent - scrollController.position.minScrollExtent;

    int firstVisibleItemIndex = (scrollOffset / (scrollRange + viewportHeight) * itemCount).floor();
    int lastVisibleItemIndex = firstVisibleItemIndex + numberOfItemOnViewPort();

    return [firstVisibleItemIndex, lastVisibleItemIndex];
  }
}
