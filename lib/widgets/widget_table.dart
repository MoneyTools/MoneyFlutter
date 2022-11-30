import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:money/models/money_entity.dart';

import '../helpers.dart';
import 'columns.dart';
import 'widget_view.dart';

class TableWidget extends StatefulWidget {
  final List<ColumnDefinition> columns;
  final List<MoneyEntity> list;

  const TableWidget({super.key, required this.columns, required this.list});

  @override
  State<TableWidget> createState() => TableWidgetState();
}

class TableWidgetState extends State<TableWidget> {
  List<int> selectedItems = [0];
  final double itemHeight = 30;
  final scrollController = ScrollController();

  List<ColumnDefinition> getColumnDefinitions() {
    return [];
  }

  final formatCurrency = NumberFormat("#,##0.00", "en_US");

  int sortBy = 0;
  bool sortAscending = true;

  @override
  Widget build(BuildContext context) {
    return Focus(
        autofocus: true,
        onFocusChange: (focused) {
          setState(() {
            // _color = focused ? Colors.black26 : Colors.white;
            // _label = focused ? 'Focused' : 'Unfocused';
          });
        },
        onKey: (node, event) {
          return onListViewKeyEvent(node, event);
        },
        child: ListView.builder(
            // physics: const NeverScrollableScrollPhysics(),
            primary: false,
            controller: scrollController,
            itemCount: widget.list.length,
            itemExtent: itemHeight,
            // cacheExtent: itemHeight * 1000,
            itemBuilder: (context, index) {
              return getRow(widget.list, index);
            }));
  }

  onListViewKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
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
    List<Widget> cells = [];
    for (int i = 0; i < widget.columns.length; i++) {
      cells.add(getCell(i, widget.columns[i].getCell!(index)));
    }
    var backgroundColor = selectedItems.contains(index) ? getColorTheme(context).tertiaryContainer : Colors.transparent;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedItems.clear();
          selectedItems.add(index);
        });
      },
      child: Container(
        color: backgroundColor,
        child: Row(children: cells),
      ),
    );
  }

  Widget getCell(int columnId, Object value) {
    var columnDefinition = widget.columns[columnId];
    switch (columnDefinition.type) {
      case ColumnType.amount:
        return renderColumValueEntryCurrency(value);
      case ColumnType.text:
      default:
        return renderColumValueEntryText(value, textAlign: columnDefinition.align);
    }
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
