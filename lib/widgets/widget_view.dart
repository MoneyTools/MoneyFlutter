import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../helpers.dart';
import '../widgets/header.dart';
import 'columns.dart';
import 'widget_table.dart';

class ViewWidget extends StatefulWidget {
  const ViewWidget({super.key});

  @override
  State<ViewWidget> createState() => ViewWidgetState();
}

class ViewWidgetState extends State<ViewWidget> {
  ColumnDefinitions columns = ColumnDefinitions([]);
  List<int> selectedItems = [0];
  final double itemHeight = 30;
  final scrollController = ScrollController();

  ColumnDefinitions getColumnDefinitions() {
    return ColumnDefinitions([]);
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
    List<Widget> headers = getHeadersWidgets(context, columns, changeListSortOrder);
    return Row(children: headers);
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

    return Expanded(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Column(
              children: <Widget>[
                getTitle(),
                getTableHeaders(),
                Expanded(child: TableWidget(list: getList(), columns: columns, onTap: onShowPanelForItemDetails)),
              ],
            )));
  }

  onShowPanelForItemDetails(context, index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: getDetailPanelHeader(context, index, list[index]),
            content: getDetailPanelContent(context, index, list[index]),
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
  }

  getDetailPanelHeader(context, index, item) {
    return Center(child: Text('${getClassNameSingular()} #${index + 1}'));
  }

  getDetailPanelContent(context, index, item) {
    return Center(child: Column(children: columns.getCellsForDetailsPanel(index)));
  }

  List<Widget> getHeadersWidgets(BuildContext context, ColumnDefinitions columns, Function changeSort) {
    List<Widget> headers = [];
    for (var i = 0; i < columns.list.length; i++) {
      headers.add(
        headerButton(
          context,
          columns.list[i].name,
          columns.list[i].align,
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
