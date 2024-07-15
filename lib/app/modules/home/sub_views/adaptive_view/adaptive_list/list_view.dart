// Imports
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/app/core/helpers/ranges.dart';
import 'package:money/app/data/models/fields/fields.dart';
import 'package:money/app/data/models/money_objects/money_object.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_item.dart';

// Exports
export 'package:money/app/data/models/fields/fields.dart';
export 'package:money/app/data/models/money_objects/money_object.dart';
export 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_item.dart';
export 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_item_card.dart';
export 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_item_header.dart';

class MyListView<T> extends StatefulWidget {
  const MyListView({
    required this.fields,
    required this.list,
    required this.selectedItemIds,
    super.key,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.displayAsColumn = true,
    this.onSelectionChanged,
    this.isMultiSelectionOn = false,
  });

  final Function(BuildContext, int)? onTap;
  final Function(BuildContext, int)? onDoubleTap;
  final Function(BuildContext, int)? onLongPress;
  final Function(int /* uniqueId */)? onSelectionChanged;
  final bool displayAsColumn;
  final Fields<T> fields;
  final bool isMultiSelectionOn;
  final List<T> list;
  final ValueNotifier<List<int>> selectedItemIds;

  @override
  State<MyListView<T>> createState() => MyListViewState<T>();
}

class MyListViewState<T> extends State<MyListView<T>> {
  double padding = 0;
  double rowHeight = 30;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // render the list with the first selected item in view
    double initialScrollOffset = 0;

    if (widget.selectedItemIds.value.isNotEmpty) {
      final int firstSelectedIndex = getListIndexFromUniqueId(widget.selectedItemIds.value.first);
      if (firstSelectedIndex != -1) {
        initialScrollOffset = (firstSelectedIndex * rowHeight);
        // don't make it flush to the top, we do this in order to give some clue that there's other item above,
        initialScrollOffset += rowHeight * -1.5;
      }
    }
    scrollController = ScrollController(initialScrollOffset: initialScrollOffset);
  }

  @override
  Widget build(final BuildContext context) {
    final TextScaler textScaler = MediaQuery.textScalerOf(context);

    if (widget.displayAsColumn) {
      rowHeight = 30;
      padding = 8.0;
    } else {
      rowHeight = 85;
      padding = 0;
    }

    return ListView.builder(
      primary: false,
      scrollDirection: Axis.vertical,
      controller: scrollController,
      itemCount: widget.list.length,
      itemExtent: textScaler.scale(rowHeight),
      itemBuilder: (final BuildContext context, final int index) {
        final MoneyObject itemInstance = getMoneyObjectFromIndex(index);
        final isLastItemOfTheList = (index == widget.list.length - 1);
        final isSelected = widget.selectedItemIds.value.contains(itemInstance.uniqueId);
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isMultiSelectionOn)
                Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedItem(itemInstance.uniqueId);
                      }
                      if (value == false) {
                        widget.selectedItemIds.value.remove(itemInstance.uniqueId);
                      }
                      widget.onSelectionChanged?.call(itemInstance.uniqueId);
                      FocusScope.of(context).requestFocus();
                    });
                  },
                ),
              Expanded(
                child: MyListItem(
                  onListViewKeyEvent: onListViewKeyEvent,
                  onTap: () {
                    if (widget.selectedItemIds.value.contains(itemInstance.uniqueId)) {
                      widget.selectedItemIds.value.remove(itemInstance.uniqueId);
                    } else {
                      if (widget.isMultiSelectionOn == false) {
                        // single selection
                        widget.selectedItemIds.value.clear();
                      }
                      widget.selectedItemIds.value.add(itemInstance.uniqueId);
                    }
                    widget.onSelectionChanged?.call(itemInstance.uniqueId);

                    FocusScope.of(context).requestFocus();
                  },
                  onLongPress: () {
                    widget.onLongPress?.call(context, itemInstance.uniqueId);
                    FocusScope.of(context).requestFocus();
                  },
                  autoFocus: index == widget.selectedItemIds.value.firstOrNull,
                  isSelected: isSelected,
                  adornmentColor: itemInstance.getMutationColor(),
                  child: _buildListItemContent(
                    isSelected,
                    itemInstance,
                    isLastItemOfTheList,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// return -1 if not found
  int getListIndexFromUniqueId(final int uniqueId) {
    return widget.list.indexWhere((element) => (element as MoneyObject).uniqueId == uniqueId);
  }

  MoneyObject getMoneyObjectFromIndex(int index) {
    return widget.list[index] as MoneyObject;
  }

  int getUniqueIdFromIndex(int index) {
    return getMoneyObjectFromIndex(index).uniqueId;
  }

// use this if total item count is known
  NumRange indexOfItemsInView() {
    final int itemCount = widget.list.length;
    final double scrollOffset = scrollController.position.pixels;
    final double viewportHeight = scrollController.position.viewportDimension;
    final double scrollRange = scrollController.position.maxScrollExtent - scrollController.position.minScrollExtent;

    final int firstVisibleItemIndex = (scrollOffset / (scrollRange + viewportHeight) * itemCount).floor();
    final int lastVisibleItemIndex = firstVisibleItemIndex + numberOfItemOnViewPort();

    return NumRange(min: firstVisibleItemIndex, max: lastVisibleItemIndex);
  }

  bool isIndexInView(final int index) {
    if (index != -1) {
      final NumRange viewingIndexRange = indexOfItemsInView();
      if (index.isBetween(viewingIndexRange.min, viewingIndexRange.max)) {
        return true;
      }
    }
    return false;
  }

  int numberOfItemOnViewPort() {
    final double viewportHeight = scrollController.position.viewportDimension;
    final int numberOfItemDisplayed = (viewportHeight / rowHeight).ceil();
    return numberOfItemDisplayed;
  }

  KeyEventResult onListViewKeyEvent(
    final FocusNode node,
    final KeyEvent event,
  ) {
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
          selectedItem(0);
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.end) {
        setState(() {
          selectedItem(widget.list.length - 1);
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
    return KeyEventResult.ignored;
  }

  void scrollToId(final int uniqueId) {
    final int index = getListIndexFromUniqueId(uniqueId);
    scrollToIndex(index);
  }

  void scrollToIndex(final int index) {
    if (!isIndexInView(index)) {
      final double desiredNewPosition = rowHeight * index;
      scrollController.jumpTo(desiredNewPosition);
    }
  }

  void selectedItem(final int uniqueId) {
    setState(() {
      if (widget.isMultiSelectionOn == false) {
        // single selection so remove any other selection before selecting an item
        widget.selectedItemIds.value.clear();
      }

      // only add it if its not already there
      if (!widget.selectedItemIds.value.contains(uniqueId)) {
        widget.selectedItemIds.value.add(uniqueId);
        widget.onSelectionChanged?.call(uniqueId);
      }
    });
  }

  void selectedItemOffset(final int delta) {
    int newPosition = 0;
    if (widget.selectedItemIds.value.isNotEmpty) {
      newPosition = widget.selectedItemIds.value[0] + delta;
    }

    selectedItem(newPosition);
  }

  Widget _buildListItemContent(
    final bool isSelected,
    final MoneyObject itemInstance,
    final bool isLastItemOfTheList,
  ) {
    return widget.displayAsColumn
        ? itemInstance.buildFieldsAsWidgetForLargeScreen!(
            widget.fields,
            itemInstance as T,
          )
        : Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: isLastItemOfTheList ? Colors.transparent : Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: itemInstance.buildFieldsAsWidgetForSmallScreen!(),
          );
  }
}
