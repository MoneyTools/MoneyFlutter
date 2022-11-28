import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../helpers.dart';
import '../widgets/header.dart';
import 'columns.dart';

class ViewWidget extends StatefulWidget {
  const ViewWidget({super.key});

  @override
  State<ViewWidget> createState() => ViewWidgetState();
}

class ViewWidgetState extends State<ViewWidget> {
  List<ColumnDefinition> columns = [];
  List<int> selectedItems = [0];
  final double itemHeight = 30;
  final scrollController = ScrollController();

  List<ColumnDefinition> getColumnDefinitions() {
    return [];
  }

  var list = [];

  final formatCurrency = NumberFormat("#,##0.00", "en_US");

  int sortBy = 0;
  bool sortAscending = true;

  ViewWidgetState();

  @override
  void initState() {
    super.initState();
    columns = getColumnDefinitions();
    sortBy = getDefaultSortColumn();
    list = getList();
  }

  getList() {
    return [];
  }

  getDefaultSortColumn() {
    return sortBy;
  }

  onSort() {
    return list.sort((a, b) {
      return columns[sortBy].sorting!(a, b, sortAscending);
    });
  }

  Widget getTitle() {
    return const Header("", 0, "");
  }

  Widget getTableHeaders() {
    List<Widget> headers = getHeadersWidgets(context, columns, changeListSortOrder);
    return Row(children: headers);
  }

  Widget getRow(list, index) {
    List<Widget> cells = [];
    for (int i = 0; i < columns.length; i++) {
      cells.add(getCell(i, columns[i].getCell!(index)));
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
    var columnDefinition = columns[columnId];
    switch (columnDefinition.type) {
      case ColumnType.amount:
        return renderColumValueEntryCurrency(value);
      case ColumnType.text:
      default:
        return renderColumValueEntryText(value, textAlign: columnDefinition.align);
    }
  }

  @override
  Widget build(BuildContext context) {
    onSort();

    return Expanded(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Column(
              children: <Widget>[
                getTitle(),
                getTableHeaders(),
                Expanded(
                    child: Focus(
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
                        child: getListViewBuilder())),
              ],
            )));
  }

  onListViewKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowUp && event.runtimeType.toString() == 'RawKeyDownEvent') {
      setState(() {
        changeSelectionPosition(-1);
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown && event.runtimeType.toString() == 'RawKeyDownEvent') {
      setState(() {
        changeSelectionPosition(1);
      });
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void changeSelectionPosition(int delta) {
    int newPosition = 0;
    if (selectedItems.isNotEmpty) {
      newPosition = selectedItems[0] + delta;
    }

    if (newPosition.isBetween(-1, list.length)) {
      selectedItems.clear();
      selectedItems.add(newPosition);
      scrollToIndex(newPosition);
    }
  }

  void scrollToIndex(int index) {
    var minMax = scrollListenerWithItemCount();

    print("${minMax[0]} > $index < ${minMax[0]}");

    if (!index.isBetween(minMax[0], minMax[1])) {
      double desiredNewPosition = itemHeight * index;
      scrollController.jumpTo(desiredNewPosition);
    }
  }

  // use this if total item count is known
  scrollListenerWithItemCount() {
    int itemCount = list.length;
    double scrollOffset = scrollController.position.pixels;
    double viewportHeight = scrollController.position.viewportDimension;
    double scrollRange = scrollController.position.maxScrollExtent - scrollController.position.minScrollExtent;
    int firstVisibleItemIndex = (scrollOffset / (scrollRange + viewportHeight) * itemCount).ceil();
    int lastVisibleItemIndex = (scrollOffset / itemHeight).ceil();
    return [firstVisibleItemIndex, lastVisibleItemIndex];
  }

  getListViewBuilder() {
    return ListView.builder(
        physics: const ClampingScrollPhysics(),
        controller: scrollController,
        itemCount: list.length,
        itemExtent: itemHeight,
        // cacheExtent: itemHeight * 1000,
        itemBuilder: (context, index) {
          return getRow(list, index);
        });
  }

  List<Widget> getHeadersWidgets(BuildContext context, columns, Function changeSort) {
    List<Widget> headers = [];
    for (var i = 0; i < columns.length; i++) {
      headers.add(
        headerButton(
          context,
          columns[i].name,
          columns[i].align,
          getSortIndicated(i),
          () {
            changeSort(i, !sortAscending);
          },
        ),
      );
    }
    return headers;
  }

  changeListSortOrder(newSortOrder, newSortAscending) {
    setState(() {
      sortBy = newSortOrder;
      sortAscending = newSortAscending;
    });
  }

  getSortIndicated(columnNumber) {
    if (columnNumber == sortBy) {
      return sortAscending ? SortIndicator.sortAscending : SortIndicator.sortDescending;
    }
    return SortIndicator.none;
  }
}

enum SortIndicator { none, sortAscending, sortDescending }

getSortIconName(SortIndicator sortIndicator) {
  switch (sortIndicator) {
    case SortIndicator.sortAscending:
      return const Icon(Icons.arrow_upward, size: 20.0);
    case SortIndicator.sortDescending:
      return const Icon(Icons.arrow_downward, size: 20.0);
    case SortIndicator.none:
    default:
      return null;
  }
}

Widget headerButton(context, text, textAlign, SortIndicator sortIndicator, onClick) {
  return Expanded(
    child: Container(
      color: getColorTheme(context).secondaryContainer,
      child: textButtonOptionalIcon(context, text, textAlign, sortIndicator, onClick),
    ),
  );
}

TextButton textButtonOptionalIcon(context, String text, textAlign, SortIndicator sortIndicator, onClick) {
  final textTheme = getTextTheme(context).apply(displayColor: getColorTheme(context).onSurface);
  var icon = getSortIconName(sortIndicator);

  List<Widget> rowChildren = [
    Text(text, style: textTheme.titleMedium),
  ];

  if (icon != null) {
    rowChildren.add(icon);
  }

  return TextButton(
    onPressed: onClick,
    child: Row(mainAxisAlignment: getRowAlignmentBasedOnTextAlign(textAlign), children: rowChildren),
  );
}

MainAxisAlignment getRowAlignmentBasedOnTextAlign(TextAlign textAlign) {
  switch (textAlign) {
    case TextAlign.left:
      return MainAxisAlignment.start;
    case TextAlign.right:
      return MainAxisAlignment.end;
    case TextAlign.center:
    default:
      return MainAxisAlignment.center;
  }
}

Widget renderColumValueEntryText(text, {TextAlign textAlign = TextAlign.left}) {
  return Expanded(
      child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: textAlign == TextAlign.left ? Alignment.centerLeft : Alignment.center,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
            child: Text(text, textAlign: textAlign),
          )));
}

Widget renderColumValueEntryCurrency(value) {
  return Expanded(
      child: FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerRight,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: Text(
        getCurrencyText(value),
        textAlign: TextAlign.right,
      ),
    ),
  ));
}
