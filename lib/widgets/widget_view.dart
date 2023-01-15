import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/widgets/widgets.dart';

import '../helpers.dart';
import '../widgets/header.dart';
import 'bottom.dart';
import 'columns.dart';
import 'widget_bar_chart.dart';
import 'widget_table.dart';

typedef FilterFunction = bool Function(dynamic);

bool defaultFilter(element) {
  return true; // filter nothing
}

T? getFirstElement<T>(List<int> indices, list) {
  if (indices.isNotEmpty) {
    int index = indices.first;
    var T = list[index];
    if (T != null) {
      return T;
    }
  }
  return null;
}

class ViewWidget extends StatefulWidget {
  final bool showTitle;
  final bool showBottom;
  final bool expandAndPadding;
  final FilterFunction filter;

  const ViewWidget({super.key, this.showTitle = true, this.showBottom = true, this.expandAndPadding = true, this.filter = defaultFilter});

  @override
  State<ViewWidget> createState() => ViewWidgetState();
}

class ViewWidgetState extends State<ViewWidget> {
  ColumnDefinitions columns = ColumnDefinitions([]);
  List<int> selectedItems = [0];
  final double itemHeight = 30;
  final scrollController = ScrollController();

  var list = [];
  var listOfUniqueInstances = [];

  final formatCurrency = NumberFormat("#,##0.00", "en_US");
  bool isBottomPanelExpanded = false;
  num selectedBottomTabId = 0;

  int sortBy = 0;
  bool sortAscending = true;
  bool isChecked = true;
  Object? subViewSelectedItem;

  ViewWidgetState();

  ColumnDefinitions getColumnDefinitionsForTable() {
    return ColumnDefinitions([]);
  }

  ColumnDefinitions getColumnDefinitionsForDetailsPanel() {
    return getColumnDefinitionsForTable();
  }

  @override
  void initState() {
    super.initState();
    columns = getColumnDefinitionsForTable();
    sortBy = getDefaultSortColumn();
    list = getList();
  }

  String getClassNamePlural() {
    return "Items";
  }

  String getClassNameSingular() {
    return "Item";
  }

  String getDescription() {
    return "Default list of items";
  }

  getList() {
    return [];
  }

  getDefaultSortColumn() {
    return sortBy;
  }

  onSort() {
    return list.sort((a, b) {
      return columns.list[sortBy].sorting!(a, b, sortAscending);
    });
  }

  Widget getTitle() {
    return Header(getClassNamePlural(), numValueOrDefault(list.length), getDescription());
  }

  Widget getTableHeaders() {
    return Container(
      color: getColorTheme(context).secondaryContainer,
      child: Row(
        children: getHeadersWidgets(context, columns, changeListSortOrder, onCustomizeColumn),
      ),
    );
  }

  Widget getRow(list, index) {
    List<Widget> cells = columns.getCellsForRow(index);
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

  @override
  Widget build(BuildContext context) {
    onSort();

    // UI areas to display
    List<Widget> list = [];

    if (widget.showTitle) {
      list.add(getTitle());
    }

    // UI for Table
    list.add(getTableHeaders());
    list.add(Expanded(child: TableWidget(list: getList(), columns: columns, onTap: onRowTap)));

    if (widget.showBottom) {
      list.add(BottomPanel(
        isExpanded: isBottomPanelExpanded,
        onExpanded: (isExpanded) {
          setState(() {
            isBottomPanelExpanded = isExpanded;
          });
        },
        selectedTabId: selectedBottomTabId,
        selectedItems: selectedItems,
        subViewSelectedItem: subViewSelectedItem,
        onTabActivated: updateBottomContent,
        getBottomContentToRender: getSubViewContent,
      ));
    }

    if (widget.expandAndPadding) {
      return getViewExpandAndPadding(Column(children: list));
    }

    return Column(children: list);
  }

  updateBottomContent(tab) {
    setState(() {
      selectedBottomTabId = tab;
    });
  }

  Widget getSubViewContent(subViewId, selectedItems) {
    switch (subViewId) {
      case 0:
        return getSubViewContentForDetails(selectedItems);
      case 1:
        return getSubViewContentForChart(selectedItems);
      case 2:
        return getSubViewContentForTransactions(selectedItems);
      default:
        return const Text("- empty -");
    }
  }

  onRowTap(context, index) {
    if (isMobile()) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: getDetailPanelHeader(context, index, list[index]),
              content: getSubViewContentForDetails([index]),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Discard'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Apply'),
                )
              ],
            );
          });
    } else {
      // This will cause a UI update and the bottom details will get rendered if its expanded
      setState(() {
        selectedItems.clear();
        selectedItems.add(index);
      });
    }
  }

  getDetailPanelHeader(context, index, item) {
    return Center(child: Text('${getClassNameSingular()} #${index + 1}'));
  }

  getSubViewContentForDetails(List<int> indices) {
    var detailPanelFields = getColumnDefinitionsForDetailsPanel();
    if (indices.isNotEmpty) {
      var index = indices.first;
      return Center(
        key: Key(index.toString()),
        child: Column(children: detailPanelFields.getCellsForDetailsPanel(index)),
      );
    }
  }

  getSubViewContentForChart(List<int> indices) {
    List<CategoryValue> list = [];
    list.add(CategoryValue("a", 12.2));
    list.add(CategoryValue("b", 22.2));
    list.add(CategoryValue("c", 11.2));
    list.add(CategoryValue("d", 14.2));

    return WidgetBarChart(list: list);
  }

  getSubViewContentForTransactions(List<int> indices) {
    return const Text("the transactions");
  }

  List<Widget> getHeadersWidgets(BuildContext context, ColumnDefinitions columns, Function changeSort, Function customizeColumn) {
    List<Widget> headers = [];
    for (var i = 0; i < columns.list.length; i++) {
      headers.add(
        headerButton(
          context,
          columns.list[i].name,
          columns.list[i].align,
          getSortIndicated(i),
          // Press
          () {
            changeSort(i, !sortAscending);
          },
          // Long Press
          () {
            customizeColumn(columns.list[i]);
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

  getUniqueInstances(ColumnDefinition columnToCustomerFilterOn) {
    var set = <String>{}; // This is a Set()
    var list = getList();
    for (var i = 0; i < list.length; i++) {
      var fieldValue = columnToCustomerFilterOn.getFieldValue!(i);
      set.add(fieldValue);
    }
    var uniqueValues = set.toList();
    uniqueValues.sort();
    return uniqueValues;
  }

  getMinMaxValues(ColumnDefinition columnToCustomerFilterOn) {
    num min = 0;
    num max = 0;
    var list = getList();
    for (var i = 0; i < list.length; i++) {
      var fieldValue = columnToCustomerFilterOn.getFieldValue!(i);
      if (min > fieldValue) {
        min = fieldValue;
      }
      if (max < fieldValue) {
        max = fieldValue;
      }
    }

    return [min, max];
  }

  getMinMaxDates(ColumnDefinition columnToCustomerFilterOn) {
    String min = "";
    String max = "";

    var list = getList();

    for (var i = 0; i < list.length; i++) {
      var fieldValue = columnToCustomerFilterOn.getFieldValue!(i);
      if (min.isEmpty || min.compareTo(fieldValue) == 1) {
        min = fieldValue;
      }
      if (max.isEmpty || max.compareTo(fieldValue) == -1) {
        max = fieldValue;
      }
    }

    return [min, max];
  }

  onCustomizeColumn(ColumnDefinition columnToCustomerFilterOn) {
    Widget content;

    switch (columnToCustomerFilterOn.type) {
      case ColumnType.amount:
        {
          var minMax = getMinMaxValues(columnToCustomerFilterOn);
          content = Column(children: [
            Text(getCurrencyText(minMax[0])),
            Text(getCurrencyText(minMax[1])),
          ]);
          break;
        }

      case ColumnType.date:
        {
          var minMax = getMinMaxDates(columnToCustomerFilterOn);
          content = Column(children: [
            Text(minMax[0]),
            Text(minMax[1]),
          ]);
          break;
        }
      case ColumnType.text:
      default:
        {
          listOfUniqueInstances = getUniqueInstances(columnToCustomerFilterOn);
          content = ListView.builder(
              itemCount: listOfUniqueInstances.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(listOfUniqueInstances[index].toString()),
                  value: true,
                  onChanged: (isChecked) {},
                );
              });
          break;
        }
    }

    showDialog(
        context: context,
        builder: (context) {
          return Material(
              child: AlertDialog(
            title: const Text("Filter"),
            content: SizedBox(width: 400, height: 400, child: content),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Discard'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Apply'),
              )
            ],
          ));
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

Widget headerButton(context, text, textAlign, SortIndicator sortIndicator, onClick, onLongPress) {
  return Expanded(
    child: textButtonOptionalIcon(context, text, textAlign, sortIndicator, onClick, onLongPress),
  );
}

Widget textButtonOptionalIcon(context, String text, textAlign, SortIndicator sortIndicator, onClick, onLongPress) {
  final textTheme = getTextTheme(context).apply(displayColor: getColorTheme(context).onSurface);
  var icon = getSortIconName(sortIndicator);

  List<Widget> rowChildren = [];

  rowChildren.add(Text(text, style: textTheme.titleSmall));

  if (icon != null) {
    rowChildren.add(icon);
  }

  return TextButton(
    onPressed: onClick,
    onLongPress: onLongPress,
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
