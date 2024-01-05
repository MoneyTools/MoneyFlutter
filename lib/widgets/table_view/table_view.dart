import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/widgets/columns.dart';
import 'package:money/widgets/table_view/table_row.dart';

class MyTableView<T> extends StatefulWidget {
  final ColumnDefinitions<T> columns;
  final List<T> list;
  final Function? onTap;
  final Function? onDoubleTap;

  const MyTableView({
    super.key,
    required this.columns,
    required this.list,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  State<MyTableView<T>> createState() => MyTableViewState<T>();
}

class MyTableViewState<T> extends State<MyTableView<T>> {
  List<int> selectedItems = <int>[0];
  final double itemHeight = 30;
  final ScrollController scrollController = ScrollController();
  num currentIndex = 0;

  ColumnDefinitions<T> getColumnDefinitions() {
    return ColumnDefinitions<T>(list: <ColumnDefinition<T>>[]);
  }

  @override
  Widget build(final BuildContext context) {
    return ListView.builder(
        primary: false,
        scrollDirection: Axis.vertical,
        controller: scrollController,
        itemCount: widget.list.length,
        itemExtent: itemHeight,
        itemBuilder: (final BuildContext context, final int index) {
          return MyTableRow(
            onListViewKeyEvent: onListViewKeyEvent,
            onTap: () {
              setSelectedItem(index);
              FocusScope.of(context).requestFocus();
            },
            // onDoubleTap: () {
            //   setSelectedItem(index, true);
            //   FocusScope.of(context).requestFocus();
            // },
            autoFocus: index == currentIndex,
            isSelected: selectedItems.contains(index),
            children: getCells(index),
          );
        });
  }

  KeyEventResult onListViewKeyEvent(final FocusNode node, final RawKeyEvent event) {
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
          debugLog(event.logicalKey.toString());
        }
      }
    }
    return KeyEventResult.ignored;
  }

  List<Widget> getCells(final int index) {
    return widget.columns.getCellsForRow(index);
  }

  void selectedItemOffset(final int delta) {
    int newPosition = 0;
    if (selectedItems.isNotEmpty) {
      newPosition = selectedItems[0] + delta;
    }

    setSelectedItem(newPosition);
  }

  void setSelectedItem(
    final int newPosition, [
    final bool isDoubleTap = false,
  ]) {
    if (newPosition.isBetween(-1, widget.list.length)) {
      setState(() {
        selectedItems.clear();
        selectedItems.add(newPosition);
        currentIndex = newPosition;
      });

      scrollToIndex(newPosition);
      if (isDoubleTap) {
        widget.onDoubleTap?.call(context, newPosition);
      } else {
        widget.onTap?.call(context, newPosition);
      }
    }
  }

  void scrollToIndex(final int index) {
    final List<int> minMax = scrollListenerWithItemCount();

    // debugLog("${minMax[0]} > $index < ${minMax[1]}");

    if (!index.isBetween(minMax[0], minMax[1])) {
      final double desiredNewPosition = itemHeight * index;
      scrollController.jumpTo(desiredNewPosition);
    }
  }

  int numberOfItemOnViewPort() {
    final double viewportHeight = scrollController.position.viewportDimension;
    final int numberOfItemDisplayed = (viewportHeight / itemHeight).ceil();
    return numberOfItemDisplayed;
  }

  // use this if total item count is known
  List<int> scrollListenerWithItemCount() {
    final int itemCount = widget.list.length;
    final double scrollOffset = scrollController.position.pixels;
    final double viewportHeight = scrollController.position.viewportDimension;
    final double scrollRange = scrollController.position.maxScrollExtent - scrollController.position.minScrollExtent;

    final int firstVisibleItemIndex = (scrollOffset / (scrollRange + viewportHeight) * itemCount).floor();
    final int lastVisibleItemIndex = firstVisibleItemIndex + numberOfItemOnViewPort();

    return <int>[firstVisibleItemIndex, lastVisibleItemIndex];
  }
}
