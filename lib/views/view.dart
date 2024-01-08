import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/helpers/json_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/settings.dart';
import 'package:money/widgets/fields/field.dart';
import 'package:money/widgets/table_view/table_header.dart';
import 'package:money/widgets/table_view/table_transactions.dart';
import 'package:money/widgets/widgets.dart';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/widgets/header.dart';
import 'package:money/widgets/details_panel.dart';
import 'package:money/widgets/fields/fields.dart';
import 'package:money/widgets/table_view/table_view.dart';

class ViewWidget<T> extends StatefulWidget {
  final FilterFunction filter;
  final ViewWidgetToDisplay preference;

  const ViewWidget({super.key, this.filter = defaultFilter, this.preference = const ViewWidgetToDisplay()});

  @override
  State<ViewWidget<T>> createState() => ViewWidgetState<T>();
}

class ViewWidgetState<T> extends State<ViewWidget<T>> {
  FieldDefinitions<T> columns = FieldDefinitions<T>(list: <FieldDefinition<T>>[]);

  final ValueNotifier<List<int>> selectedItems = ValueNotifier<List<int>>(<int>[]);
  final double itemHeight = 30;
  final ScrollController scrollController = ScrollController();

  List<T> list = <T>[];
  List<String> listOfUniqueInstances = <String>[];

  final NumberFormat formatCurrency = NumberFormat('#,##0.00', 'en_US');
  bool isBottomPanelExpanded = false;
  int selectedBottomTabId = 0;

  int sortByColumn = 0;
  bool sortAscending = true;
  bool isChecked = true;
  Object? subViewSelectedItem;

  ViewWidgetState() {
    assert(T != dynamic, 'Type T cannot be dynamic');
  }

  FieldDefinitions<T> getFieldDefinitionsForTable() {
    return FieldDefinitions<T>(list: <FieldDefinition<T>>[]);
  }

  FieldDefinitions<T> getFieldDefinitionsForDetailsPanel() {
    return getFieldDefinitionsForTable();
  }

  @override
  void initState() {
    super.initState();
    columns = getFieldDefinitionsForTable();

    final Json? viewSetting = Settings().views[getClassNameSingular()];
    if (viewSetting != null) {
      sortByColumn = jsonGetInt(
        viewSetting,
        prefSortBy,
        getDefaultSortColumn(),
      );
      sortAscending = jsonGetBool(
        viewSetting,
        prefSortAscending,
        true,
      );
    }

    list = getList();

    onSort();
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
    return sortByColumn;
  }

  void onSort() {
    if (columns.list.isNotEmpty) {
      final FieldDefinition<T> fieldDefinition = columns.list[sortByColumn];
      final int Function(T p1, T p2, bool p3) sortFunction = fieldDefinition.sort;

      list.sort((final T a, final T b) {
        return sortFunction(a, b, sortAscending);
      });
    }
  }

  Widget getTitle() {
    return Header(getClassNamePlural(), numValueOrDefault(list.length), getDescription());
  }

  @override
  Widget build(final BuildContext context) {
    return getViewExpandAndPadding(
      Column(
        children: <Widget>[
          // Optional upper Title area
          if (widget.preference.showTitle) getTitle(),

          // Table Header
          MyTableHeader<T>(
            columns: columns,
            sortByColumn: sortByColumn,
            sortAscending: sortAscending,
            onTap: changeListSortOrder,
            onLongPress: onCustomizeColumn,
          ),

          // Table rows
          Expanded(
            flex: 1,
            child: MyTableView<T>(
              list: getList(),
              columns: columns,
              onTap: onRowTap,
              // onDoubleTap: (final BuildContext context, final int index) {
              //   if (widget.preference.showBottom) {
              //     setState(() {
              //       isBottomPanelExpanded = true;
              //     });
              //   }
            ),
          ),

          // Optional bottom details panel
          if (widget.preference.showBottom)
            Expanded(
              flex: isBottomPanelExpanded ? 1 : 0,
              // this will split the vertical view when expanded
              child: DetailsPanel(
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
              ),
            ),
        ],
      ),
    );
  }

  Widget getViewExpandAndPadding(final Widget child) {
    return Expanded(
      child: Container(
          color: Theme.of(context).colorScheme.background,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: child),
    );
  }

  updateBottomContent(final int tab) {
    setState(() {
      selectedBottomTabId = tab;
    });
  }

  Widget getSubViewContent(final int subViewId, final List<int> selectedItems) {
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
      selectedItems.value = <int>[index];
    }
  }

  Widget getDetailPanelHeader(final BuildContext context, final num index, final T item) {
    return Center(child: Text('${getClassNameSingular()} #${index + 1}'));
  }

  Widget getSubViewContentForDetails(final List<int> indices) {
    final FieldDefinitions<T> detailPanelFields = getFieldDefinitionsForDetailsPanel();
    if (indices.isNotEmpty) {
      final int index = indices.first;
      return SingleChildScrollView(
        key: Key(index.toString()),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: detailPanelFields.getCellsForDetailsPanel(index),
          ),
        ),
      );
    }
    return const Text('No item selected');
  }

  Widget getSubViewContentForChart(final List<int> indices) {
    return const Text('No chart to display');
  }

  Widget getSubViewContentForTransactions(final List<int> indices) {
    return const Text('the transactions');
  }

  changeListSortOrder(final int columnNumber) {
    setState(() {
      if (columnNumber == sortByColumn) {
        // toggle order
        sortAscending = !sortAscending;
      } else {
        sortByColumn = columnNumber;
      }

      // Persist users choice
      Settings().views[getClassNameSingular()] = <String, dynamic>{
        prefSortBy: sortByColumn,
        prefSortAscending: sortAscending,
      };

      Settings().save();
      onSort();
    });
  }

  SortIndicator getSortIndicated(final int columnNumber) {
    if (columnNumber == sortByColumn) {
      return sortAscending ? SortIndicator.sortAscending : SortIndicator.sortDescending;
    }
    return SortIndicator.none;
  }

  List<String> getUniqueInstances(final FieldDefinition<T> columnToCustomerFilterOn) {
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

  List<double> getMinMaxValues(final FieldDefinition<T> columnToCustomerFilterOn) {
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

  List<String> getMinMaxDates(final FieldDefinition<T> columnToCustomerFilterOn) {
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

  onCustomizeColumn(final FieldDefinition<T> columnToCustomerFilterOn) {
    Widget content;

    switch (columnToCustomerFilterOn.type) {
      case FieldType.amount:
        {
          final List<double> minMax = getMinMaxValues(columnToCustomerFilterOn);
          content = Column(children: <Widget>[
            Text(getCurrencyText(minMax[0])),
            Text(getCurrencyText(minMax[1])),
          ]);
          break;
        }

      case FieldType.date:
        {
          final List<String> minMax = getMinMaxDates(columnToCustomerFilterOn);
          content = Column(children: <Widget>[
            Text(minMax[0]),
            Text(minMax[1]),
          ]);
          break;
        }
      case FieldType.text:
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
  final bool columnAccount;
  final List<String> columnsToInclude;

  const ViewWidgetToDisplay({
    this.showTitle = true,
    this.showBottom = true,
    this.columnAccount = true,
    this.columnsToInclude = const <String>[],
  });
}
