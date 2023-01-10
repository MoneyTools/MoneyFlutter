import 'dart:async';

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
  num currentIndex = 0;
  Timer? _timerForTap;

  ColumnDefinitions getColumnDefinitions() {
    return ColumnDefinitions([]);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        primary: false,
        scrollDirection: Axis.vertical,
        controller: scrollController,
        itemCount: widget.list.length,
        itemExtent: itemHeight,
        itemBuilder: (context, index) {
          return getRow(widget.list, index, index == currentIndex);
        });
  }

  KeyEventResult onListViewKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
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
          debugLog(event.logicalKey);
        }
      }
    }
    return KeyEventResult.ignored;
  }

  Widget getRow(list, index, autofocus) {
    List<Widget> cells = getCells(index);

    var backgroundColor = selectedItems.contains(index) ? getColorTheme(context).tertiaryContainer : Colors.transparent;

    return Focus(
        autofocus: autofocus,
        onFocusChange: (value) {
          // debugLog('focus lost $value index $currentIndex');
          if (value) {}
        },
        onKey: onListViewKeyEvent,
        child: GestureDetector(
          onTap: () {
            setSelectedItem(index);
            FocusScope.of(context).requestFocus();
          },
          child: Container(
            color: backgroundColor,
            child: Row(children: cells),
          ),
        ));
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
      setState(() {
        selectedItems.clear();
        selectedItems.add(newPosition);

        currentIndex = newPosition;
        scrollToIndex(newPosition);
        fireOnTapToHost(newPosition);
      });
    }
  }

  void fireOnTapToHost(index) {
    _timerForTap?.cancel();
    _timerForTap = Timer(const Duration(milliseconds: 600), () {
      widget.onTap(context, index);
    });
  }

  void scrollToIndex(int index) {
    var minMax = scrollListenerWithItemCount();

    // debugLog("${minMax[0]} > $index < ${minMax[1]}");

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
