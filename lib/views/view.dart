import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/helpers/json_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/settings.dart';
import 'package:money/widgets/table_view/table_header.dart';
import 'package:money/widgets/table_view/table_transactions.dart';
import 'package:money/widgets/widgets.dart';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/views/view_header.dart';
import 'package:money/widgets/details_panel.dart';
import 'package:money/widgets/table_view/table_view.dart';

class ViewWidget<T> extends StatefulWidget {
  final FilterFunction filter;
  final ViewWidgetToDisplay preference;

  const ViewWidget({super.key, this.filter = defaultFilter, this.preference = const ViewWidgetToDisplay()});

  @override
  State<ViewWidget<T>> createState() => ViewWidgetState<T>();
}

class ViewWidgetState<T> extends State<ViewWidget<T>> {
  FieldDefinitions<T> columns = FieldDefinitions<T>(definitions: <Declare<T, dynamic>>[]);

  int lastSelectedItemIndex = 0;
  ValueNotifier<List<int>> selectedItems = ValueNotifier<List<int>>(<int>[]);

  final double itemHeight = 30;
  final ScrollController scrollController = ScrollController();

  List<T> list = <T>[];
  List<String> listOfUniqueInstances = <String>[];
  String filterText = '';

  final NumberFormat formatCurrency = NumberFormat('#,##0.00', 'en_US');

  int selectedBottomTabId = 0;

  int sortByColumn = 0;
  bool sortAscending = true;
  bool isChecked = true;
  Object? subViewSelectedItem;

  ViewWidgetState() {
    assert(T != dynamic, 'Type T cannot be dynamic');
  }

  /// Derived class will override to customize the fields to display in the Adaptive Table
  FieldDefinitions<T> getFieldDefinitionsForTable() {
    return FieldDefinitions<T>(definitions: getFieldsForClass<T>());
  }

  /// Derived class will override to customize the fields to display in the details panel
  FieldDefinitions<T> getFieldDefinitionsForDetailsPanel() {
    final List<Declare<T, dynamic>> fields =
        getFieldsForClass<T>().where((final Declare<T, dynamic> item) => item.useAsDetailPanels).toList();
    return FieldDefinitions<T>(definitions: fields);
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
      lastSelectedItemIndex = jsonGetInt(viewSetting, prefSelectedListItemIndex, 0);
    }

    list = getList();

    onSort();

    /// restore selection of items
    if (lastSelectedItemIndex >= 0 && lastSelectedItemIndex < list.length) {
      // index is valid
    } else {
      lastSelectedItemIndex = 0;
    }
    selectedItems.value = <int>[lastSelectedItemIndex];
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
    if (columns.definitions.isNotEmpty) {
      if (isBetween(sortByColumn, -1, columns.definitions.length)) {
        final Declare<T, dynamic> fieldDefinition = columns.definitions[sortByColumn];
        if (fieldDefinition.sort == null) {
          list.sort((final T a, final T b) {
            switch (fieldDefinition.type) {
              case FieldType.numeric:
              case FieldType.numericShorthand:
                return sortByValue(
                  fieldDefinition.valueFromInstance(a) as num,
                  fieldDefinition.valueFromInstance(b) as num,
                  sortAscending,
                );
              case FieldType.amount:
              case FieldType.amountShorthand:
                return sortByValue(
                  fieldDefinition.valueFromInstance(a) as double,
                  fieldDefinition.valueFromInstance(b) as double,
                  sortAscending,
                );
              case FieldType.date:
                return sortByDate(
                  fieldDefinition.valueFromInstance(a) as DateTime,
                  fieldDefinition.valueFromInstance(b) as DateTime,
                  sortAscending,
                );
              case FieldType.text:
              default:
                return sortByString(
                  fieldDefinition.valueFromInstance(a).toString(),
                  fieldDefinition.valueFromInstance(b).toString(),
                  sortAscending,
                );
            }
          });
        } else {
          list.sort((final T a, final T b) {
            return fieldDefinition.sort!(a, b, sortAscending);
          });
        }
      }
    }
  }

  Widget getTitle() {
    return ViewHeader(
      title: getClassNamePlural(),
      count: numValueOrDefault(list.length),
      description: getDescription(),
    );
  }

  void onDelete(final BuildContext context, final int index) {
    // the derived class is responsible for implementing the delete operation
  }

  void onFilterTextChanged(final String text) {
    setState(() {
      filterText = text;
      list = getList();
    });
  }

  @override
  Widget build(final BuildContext context) {
    return getViewExpandAndPadding(
      Column(
        children: <Widget>[
          // Optional upper Title area
          if (widget.preference.displayHeader) getTitle(),

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
              list: list,
              selectedItems: selectedItems,
              columns: columns,
              onTap: onRowTap,
              // onDoubleTap: (final BuildContext context, final int index) {
              //   if (widget.preference.showBottom) {
              //     setState(() {
              //       isDetailsPanelExpanded = true;
              //     });
              //   }
            ),
          ),

          // Optional bottom details panel
          if (widget.preference.showBottom)
            Expanded(
              flex: Settings().isDetailsPanelExpanded ? 1 : 0,
              // this will split the vertical view when expanded
              child: DetailsPanel(
                isExpanded: Settings().isDetailsPanelExpanded,
                onExpanded: (final bool isExpanded) {
                  setState(() {
                    Settings().isDetailsPanelExpanded = isExpanded;
                    Settings().save();
                  });
                },
                selectedTabId: selectedBottomTabId,
                selectedItems: selectedItems,
                onTabActivated: updateBottomContent,
                getDetailPanelContent: getDetailPanelContent,
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
        child: child,
      ),
    );
  }

  updateBottomContent(final int tab) {
    setState(() {
      selectedBottomTabId = tab;
    });
  }

  Widget getDetailPanelContent(final int subViewId, final List<int> selectedItems) {
    switch (subViewId) {
      case 0:
        return getPanelForDetails(selectedItems);
      case 1:
        return getPanelForChart(selectedItems);
      case 2:
        return getPanelForTransactions(selectedItems);
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
              content: getPanelForDetails(<int>[index]),
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

      // call this to persist the last selected item index
      saveLastUserActionOnThisView();
    }
  }

  Widget getDetailPanelHeader(final BuildContext context, final num index, final T item) {
    return Center(child: Text('${getClassNameSingular()} #${index + 1}'));
  }

  Widget getPanelForDetails(final List<int> indices) {
    final FieldDefinitions<T> detailPanelFields = getFieldDefinitionsForDetailsPanel();
    if (indices.isNotEmpty) {
      final int index = indices.first;
      if (isBetweenOrEqual(index, 0, list.length - 1)) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                key: Key(index.toString()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: detailPanelFields.getCellsForDetailsPanel(list[index]),
                  ),
                ),
              ),
            ),
            Column(
              children: <Widget>[
                IconButton(
                    onPressed: () {
                      onDelete(context, index);
                    },
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete'),
              ],
            ),
          ],
        );
      }
    }
    return const Text('No item selected');
  }

  Widget getPanelForChart(final List<int> indices) {
    return const Text('No chart to display');
  }

  Widget getPanelForTransactions(final List<int> indices) {
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
      saveLastUserActionOnThisView();
      onSort();
    });
  }

  void saveLastUserActionOnThisView() {
    // Persist users choice
    Settings().views[getClassNameSingular()] = <String, dynamic>{
      prefSortBy: sortByColumn,
      prefSortAscending: sortAscending,
      prefSelectedListItemIndex: selectedItems.value.firstOrNull,
    };

    Settings().save();
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
      final String fieldValue = columnToCustomerFilterOn.valueFromInstance!(list[i]) as String;
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
      final double fieldValue = columnToCustomerFilterOn.valueFromInstance!(list[i]) as double;
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
      final String fieldValue = columnToCustomerFilterOn.valueFromInstance!(list[i]) as String;
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
  final bool displayHeader;
  final bool showBottom;
  final bool columnAccount;
  final List<String> columnsToInclude;

  const ViewWidgetToDisplay({
    this.displayHeader = true,
    this.showBottom = true,
    this.columnAccount = true,
    this.columnsToInclude = const <String>[],
  });
}
