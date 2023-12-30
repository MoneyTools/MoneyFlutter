import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/models/transactions.dart';
import 'package:money/widgets/widgets.dart';

import 'package:money/helpers.dart';
import 'package:money/widgets/header.dart';
import 'package:money/widgets/bottom.dart';
import 'package:money/widgets/columns.dart';
import 'package:money/widgets/widget_bar_chart.dart';
import 'package:money/widgets/widget_table.dart';

class ViewWidget<T> extends StatefulWidget {
  final FilterFunction filter;
  final ViewWidgetToDisplay preference;

  const ViewWidget({super.key, this.filter = defaultFilter, this.preference = const ViewWidgetToDisplay()});

  @override
  State<ViewWidget<T>> createState() => ViewWidgetState<T>();
}

class ViewWidgetState<T> extends State<ViewWidget<T>> {
  ColumnDefinitions<T> columns = ColumnDefinitions<T>(list: <ColumnDefinition<T>>[]);
  List<int> selectedItems = <int>[];
  final double itemHeight = 30;
  final ScrollController scrollController = ScrollController();

  List<T> list = <T>[];
  List<String> listOfUniqueInstances = <String>[];

  final NumberFormat formatCurrency = NumberFormat('#,##0.00', 'en_US');
  bool isBottomPanelExpanded = false;
  num selectedBottomTabId = 0;

  int sortBy = 0;
  bool sortAscending = true;
  bool isChecked = true;
  Object? subViewSelectedItem;

  ViewWidgetState() {
    assert(T != dynamic, 'Type T cannot be dynamic');
  }

  ColumnDefinitions<T> getColumnDefinitionsForTable() {
    return ColumnDefinitions<T>(list: <ColumnDefinition<T>>[]);
  }

  ColumnDefinitions<T> getColumnDefinitionsForDetailsPanel() {
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
    return 'Items';
  }

  String getClassNameSingular() {
    return 'Item';
  }

  String getDescription() {
    return 'Default list of items';
  }

  List<T> getList() {
    return <T>[];
  }

  int getDefaultSortColumn() {
    return sortBy;
  }

  void onSort() {
    final ColumnDefinition<T> columnDefinition = columns.list[sortBy];
    final int Function(T p1, T p2, bool p3) sortFunction = columnDefinition.sort;

    list.sort((final T a, final T b) {
      return sortFunction(a, b, sortAscending);
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

  Widget getRow(final List<T> list, final int index) {
    final List<Widget> cells = columns.getCellsForRow(index);
    final Color backgroundColor = selectedItems.contains(index) ? getColorTheme(context).tertiaryContainer : Colors.transparent;
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
  Widget build(final BuildContext context) {
    onSort();

    // UI areas to display
    final List<Widget> list = <Widget>[];

    if (widget.preference.showTitle) {
      list.add(getTitle());
    }

    // UI for Table
    list.add(getTableHeaders());
    list.add(
      Expanded(
        child: TableWidget<T>(
            list: getList(),
            columns: columns,
            onTap: onRowTap,
            onDoubleTap: (final BuildContext context, final int index) {
              if (widget.preference.showBottom) {
                setState(() {
                  isBottomPanelExpanded = true;
                });
              }
            }),
      ),
    );

    if (widget.preference.showBottom) {
      list.add(BottomPanel(
        isExpanded: isBottomPanelExpanded,
        onExpanded: (final bool isExpanded) {
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

    if (widget.preference.expandAndPadding) {
      return getViewExpandAndPadding(Column(children: list));
    }

    return Column(children: list);
  }

  updateBottomContent(final num tab) {
    setState(() {
      selectedBottomTabId = tab;
    });
  }

  Widget getSubViewContent(final num subViewId, final List<int> selectedItems) {
    switch (subViewId) {
      case 0:
        return getSubViewContentForDetails(selectedItems);
      case 1:
        return getSubViewContentForChart(selectedItems);
      case 2:
        return getSubViewContentForTransactions(selectedItems);
      default:
        return const Text('- empty -');
    }
  }

  onRowTap(final BuildContext context, final int index) {
    if (isMobile()) {
      showDialog(
          context: context,
          builder: (final BuildContext context) {
            return AlertDialog(
              title: getDetailPanelHeader(context, index, list[index]),
              content: getSubViewContentForDetails(<int>[index]),
              actions: <Widget>[
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

  Widget getDetailPanelHeader(final BuildContext context, final num index, final T item) {
    return Center(child: Text('${getClassNameSingular()} #${index + 1}'));
  }

  Widget getSubViewContentForDetails(final List<int> indices) {
    final ColumnDefinitions<T> detailPanelFields = getColumnDefinitionsForDetailsPanel();
    if (indices.isNotEmpty) {
      final int index = indices.first;
      return Center(
        key: Key(index.toString()),
        child: Column(children: detailPanelFields.getCellsForDetailsPanel(index)),
      );
    }
    return const Text('No item selected');
  }

  Widget getSubViewContentForChart(final List<num> indices) {
    final List<PairXY> list = <PairXY>[];
    list.add(PairXY('a', 12.2));
    list.add(PairXY('b', 22.2));
    list.add(PairXY('c', 11.2));
    list.add(PairXY('d', 14.2));

    return WidgetBarChart(list: list);
  }

  Widget getSubViewContentForTransactions(final List<int> indices) {
    return const Text('the transactions');
  }

  List<Widget> getHeadersWidgets(final BuildContext context, final ColumnDefinitions<T> columns, final Function changeSort, final Function customizeColumn) {
    final List<Widget> headers = <Widget>[];
    for (int i = 0; i < columns.list.length; i++) {
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

  changeListSortOrder(final int newSortOrder, final bool newSortAscending) {
    setState(() {
      sortBy = newSortOrder;
      sortAscending = newSortAscending;
    });
  }

  List<String> getUniqueInstances(final ColumnDefinition<T> columnToCustomerFilterOn) {
    final Set<String> set = <String>{}; // This is a Set()
    final List<T> list = getList();
    for (int i = 0; i < list.length; i++) {
      final String fieldValue = columnToCustomerFilterOn.value(i) as String;
      set.add(fieldValue);
    }
    final List<String> uniqueValues = set.toList();
    uniqueValues.sort();
    return uniqueValues;
  }

  List<double> getMinMaxValues(final ColumnDefinition<T> columnToCustomerFilterOn) {
    double min = 0;
    double max = 0;
    final List<T> list = getList();
    for (int i = 0; i < list.length; i++) {
      final double fieldValue = columnToCustomerFilterOn.value(i) as double;
      if (min > fieldValue) {
        min = fieldValue;
      }
      if (max < fieldValue) {
        max = fieldValue;
      }
    }

    return <double>[min, max];
  }

  List<String> getMinMaxDates(final ColumnDefinition<T> columnToCustomerFilterOn) {
    String min = '';
    String max = '';

    final List<T> list = getList();

    for (int i = 0; i < list.length; i++) {
      final String fieldValue = columnToCustomerFilterOn.value(i) as String;
      if (min.isEmpty || min.compareTo(fieldValue) == 1) {
        min = fieldValue;
      }
      if (max.isEmpty || max.compareTo(fieldValue) == -1) {
        max = fieldValue;
      }
    }

    return <String>[min, max];
  }

  onCustomizeColumn(final ColumnDefinition<T> columnToCustomerFilterOn) {
    Widget content;

    switch (columnToCustomerFilterOn.type) {
      case ColumnType.amount:
        {
          final List<double> minMax = getMinMaxValues(columnToCustomerFilterOn);
          content = Column(children: <Widget>[
            Text(getCurrencyText(minMax[0])),
            Text(getCurrencyText(minMax[1])),
          ]);
          break;
        }

      case ColumnType.date:
        {
          final List<String> minMax = getMinMaxDates(columnToCustomerFilterOn);
          content = Column(children: <Widget>[
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
              itemBuilder: (final BuildContext context, final int index) {
                return CheckboxListTile(
                  title: Text(listOfUniqueInstances[index].toString()),
                  value: true,
                  onChanged: (final bool? isChecked) {},
                );
              });
          break;
        }
    }

    showDialog(
        context: context,
        builder: (final BuildContext context) {
          return Material(
              child: AlertDialog(
            title: const Text('Filter'),
            content: SizedBox(width: 400, height: 400, child: content),
            actions: <Widget>[
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

  SortIndicator getSortIndicated(final int columnNumber) {
    if (columnNumber == sortBy) {
      return sortAscending ? SortIndicator.sortAscending : SortIndicator.sortDescending;
    }
    return SortIndicator.none;
  }
}

enum SortIndicator { none, sortAscending, sortDescending }

Widget? getSortIconName(final SortIndicator sortIndicator) {
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

Widget headerButton(final BuildContext context, final String text, final TextAlign textAlign, final SortIndicator sortIndicator, final VoidCallback? onClick, final VoidCallback? onLongPress) {
  return Expanded(
    child: textButtonOptionalIcon(context, text, textAlign, sortIndicator, onClick, onLongPress),
  );
}

Widget textButtonOptionalIcon(final BuildContext context, final String text, final TextAlign textAlign, final SortIndicator sortIndicator, final VoidCallback? onClick, final VoidCallback? onLongPress) {
  final TextTheme textTheme = getTextTheme(context).apply(displayColor: getColorTheme(context).onSurface);
  final Widget? icon = getSortIconName(sortIndicator);

  final List<Widget> rowChildren = <Widget>[];

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

MainAxisAlignment getRowAlignmentBasedOnTextAlign(final TextAlign textAlign) {
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

class ViewWidgetToDisplay {
  final bool showTitle;
  final bool showBottom;
  final bool expandAndPadding;
  final bool columnAccount;
  final List<String> columnsToInclude;

  const ViewWidgetToDisplay({this.showTitle = true, this.showBottom = true, this.expandAndPadding = true, this.columnAccount = true, this.columnsToInclude = const <String>[]});
}

typedef FilterFunction = bool Function(Transaction);

bool defaultFilter(final Transaction element) {
  return true; // filter nothing
}
