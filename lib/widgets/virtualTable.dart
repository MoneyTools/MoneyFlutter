import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../helpers.dart';
import '../widgets/header.dart';
import 'columns.dart';

class MyView extends StatefulWidget {
  const MyView({super.key});

  @override
  State<MyView> createState() => MyViewState();
}

class MyViewState extends State<MyView> {

  List<ColumnDefinition> columns = [];
  List<ColumnDefinition> getColumnDefinitions() {
    return [];
  }

  var list = [];

  final formatCurrency = NumberFormat("#,##0.00", "en_US");

  int sortBy = 0;
  bool sortAscending = true;

  MyViewState();

  @override
  void initState() {
    super.initState();
    columns = getColumnDefinitions();
    list = getList();
  }

  getList(){
    return [];
  }

  onSort() {
    return list.sort((a,b){
      return columns[sortBy].sorting!(a,b,sortAscending);
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
    return Row(children: const <Widget>[]);
  }

  @override
  Widget build(BuildContext context) {
    onSort();

    return Expanded(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Column(children: <Widget>[
              getTitle(),
              getTableHeaders(),
              Expanded(
                  child: ListView.builder(
                      itemCount: list.length,
                      itemExtent: 30,
                      // cacheExtent: 30*10000,
                      itemBuilder: (context, index) {
                        return getRow(list, index);
                      })),
            ])));
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
    child: Container(color: getColorTheme(context).secondaryContainer, child: textButtonOptionalIcon(context, text, textAlign, sortIndicator, onClick)),
  );
}

TextButton textButtonOptionalIcon(context, String text, textAlign, SortIndicator sortIndicator, onClick) {
  final textTheme = getTextTheme(context).apply(displayColor: getColorTheme(context).onSurface);
  var icon = getSortIconName(sortIndicator);
  if (icon == null) {
    return TextButton(
      onPressed: onClick,
      child: Text(text, textAlign: TextAlign.left, style: textTheme.titleMedium),
    );
  }
  return TextButton.icon(
    label: icon,
    onPressed: onClick,
    icon: Text(text, textAlign: TextAlign.left, style: textTheme.titleMedium),
  );
}
