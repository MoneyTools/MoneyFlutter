import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/widgets/table_view/list_item_columns.dart';

class MyTableView<T> extends StatefulWidget {
  final Fields<T> fields;
  final List<T> list;
  final ValueNotifier<List<int>> selectedItems;
  final Function? onTap;
  final Function? onDoubleTap;
  final bool asColumnView;

  const MyTableView({
    super.key,
    required this.fields,
    required this.list,
    required this.selectedItems,
    this.asColumnView = true,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  State<MyTableView<T>> createState() => MyTableViewState<T>();
}

class MyTableViewState<T> extends State<MyTableView<T>> {
  final double itemHeight = 30;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedItems.value.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((final _) => scrollToIndex(widget.selectedItems.value.first));
    }
  }

  @override
  Widget build(final BuildContext context) {
    return ListView.builder(
        primary: false,
        scrollDirection: Axis.vertical,
        controller: scrollController,
        itemCount: widget.list.length,
        itemExtent: widget.asColumnView ? itemHeight : 80,
        itemBuilder: (final BuildContext context, final int index) {
          final MoneyObject<T> itemInstance = (widget.list[index] as MoneyObject<T>);
          return MyListItemAsColumn(
            onListViewKeyEvent: onListViewKeyEvent,
            onTap: () {
              setSelectedItem(index);
              FocusScope.of(context).requestFocus();
            },
            autoFocus: index == widget.selectedItems.value.firstOrNull,
            isSelected: widget.selectedItems.value.contains(index),
            child: widget.asColumnView
                ? itemInstance.buildListWidgetForLargeScreen!(widget.fields, itemInstance as T)
                : itemInstance.buildListWidgetForSmallScreen!(),
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

  void selectedItemOffset(final int delta) {
    int newPosition = 0;
    if (widget.selectedItems.value.isNotEmpty) {
      newPosition = widget.selectedItems.value[0] + delta;
    }

    setSelectedItem(newPosition);
  }

  void setSelectedItem(
    final int newPosition, [
    final bool isDoubleTap = false,
  ]) {
    if (newPosition.isBetween(-1, widget.list.length)) {
      setState(() {
        widget.selectedItems.value.clear();
        widget.selectedItems.value.add(newPosition);
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
