import 'dart:async';
import 'package:flutter/material.dart';
import 'package:money/helpers/json_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/widgets/widgets.dart';
import 'package:money/views/view_header.dart';
import 'package:money/widgets/details_panel/details_panel.dart';
import 'package:money/widgets/list_view/list_view.dart';

class ViewWidget<T> extends StatefulWidget {
  const ViewWidget({
    super.key,
  });

  @override
  State<ViewWidget<T>> createState() => ViewWidgetState<T>();
}

class ViewWidgetState<T> extends State<ViewWidget<T>> {
  ViewWidgetState() {
    assert(T != dynamic, 'Type T cannot be dynamic');
  }

  // list management
  List<T> list = <T>[];
  ValueNotifier<List<int>> selectedItems = ValueNotifier<List<int>>(<int>[]);
  Fields<T> _fieldToDisplay = Fields<T>(definitions: <Field<T, dynamic>>[]);
  List<String> listOfUniqueInstances = <String>[];
  int _lastSelectedItemIndex = 0;
  int _sortByFieldIndex = 0;
  bool _sortAscending = true;

  // detail panel
  Object? subViewSelectedItem;
  int selectedBottomTabId = 0;

  // header
  String _filterText = '';
  Timer? _deadlineTimer;

  /// Derived class will override to customize the fields to display in the Adaptive Table
  Fields<T> getFieldsForTable() {
    return Fields<T>(definitions: getFieldsForClass<T>());
  }

  /// Derived class will override to customize the fields to display in the details panel
  Fields<T> getFieldsForDetailsPanel() {
    final List<Field<T, dynamic>> fields =
        getFieldsForClass<T>().where((final Field<T, dynamic> item) => item.useAsDetailPanels).toList();
    return Fields<T>(definitions: fields);
  }

  @override
  void initState() {
    super.initState();
    _fieldToDisplay = getFieldsForTable();

    final MyJson? viewSetting = Settings().views[getClassNameSingular()];
    if (viewSetting != null) {
      _sortByFieldIndex = viewSetting.getInt(prefSortBy, 0);
      _sortAscending = viewSetting.getBool(prefSortAscending, true);
      _lastSelectedItemIndex = viewSetting.getInt(prefSelectedListItemIndex, 0);
    }

    list = getList();

    onSort();

    /// restore selection of items
    if (_lastSelectedItemIndex >= 0 && _lastSelectedItemIndex < list.length) {
      // index is valid
    } else {
      _lastSelectedItemIndex = 0;
    }
    selectedItems.value = <int>[_lastSelectedItemIndex];
  }

  @override
  Widget build(final BuildContext context) {
    return LayoutBuilder(builder: (final BuildContext context, final BoxConstraints constraints) {
      final bool useColumns = !isSmallWidth(constraints);

      return buildViewContent(
        Column(
          children: <Widget>[
            // Optional upper Title area
            buildHeader(),

            if (!isSmallWidth(constraints))
              MyListItemHeader<T>(
                columns: _fieldToDisplay,
                sortByColumn: _sortByFieldIndex,
                sortAscending: _sortAscending,
                onTap: changeListSortOrder,
                onLongPress: onCustomizeColumn,
              ),

            // Table rows
            Expanded(
              flex: 1,
              child: MyTableView<T>(
                list: list,
                selectedItems: selectedItems,
                fields: _fieldToDisplay,
                asColumnView: useColumns,
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
                onActionAdd: () {},
                onActionDelete: () {
                  onDeleteRequestedByUser(context, selectedItems.value.first);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget buildViewContent(final Widget child) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: child,
    );
  }

  Widget buildHeader([final Widget? child]) {
    return ViewHeader(
      title: getClassNamePlural(),
      count: numValueOrDefault(list.length),
      description: getDescription(),
      onFilterChanged: onFilterTextChanged,
      child: child,
    );
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

  List<T> getList([bool includeDeleted = false]) {
    return <T>[];
  }

  void onSort() {
    if (_fieldToDisplay.definitions.isNotEmpty) {
      if (isBetween(_sortByFieldIndex, -1, _fieldToDisplay.definitions.length)) {
        final Field<T, dynamic> fieldDefinition = _fieldToDisplay.definitions[_sortByFieldIndex];
        if (fieldDefinition.sort == null) {
          list.sort((final T a, final T b) {
            switch (fieldDefinition.type) {
              case FieldType.numeric:
              case FieldType.numericShorthand:
                return sortByValue(
                  fieldDefinition.valueFromInstance(a) as num,
                  fieldDefinition.valueFromInstance(b) as num,
                  _sortAscending,
                );
              case FieldType.amount:
              case FieldType.amountShorthand:
                return sortByValue(
                  fieldDefinition.valueFromInstance(a) as double,
                  fieldDefinition.valueFromInstance(b) as double,
                  _sortAscending,
                );
              case FieldType.date:
                return sortByDate(
                  fieldDefinition.valueFromInstance(a) as DateTime,
                  fieldDefinition.valueFromInstance(b) as DateTime,
                  _sortAscending,
                );
              case FieldType.text:
              default:
                return sortByString(
                  fieldDefinition.valueFromInstance(a).toString(),
                  fieldDefinition.valueFromInstance(b).toString(),
                  _sortAscending,
                );
            }
          });
        } else {
          list.sort((final T a, final T b) {
            return fieldDefinition.sort!(a, b, _sortAscending);
          });
        }
      }
    }
  }

  void onDeleteRequestedByUser(final BuildContext context, final int index) {
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return DeleteConfirmationDialog(
          icon: const Icon(Icons.delete),
          title: 'Delete ${getClassNameSingular()}',
          question: 'Are you sure you want to delete this ${getClassNameSingular()}?',
          content: Column(
            children: getFieldsForTable().getListOfFieldNameAndValuePairAsWidget(list[index]),
          ),
          onConfirm: () {
            onDeleteConfirmedByUser(list[index]);
          },
        );
      },
    );
  }

  void onDeleteConfirmedByUser(final T instance) {
    // Derived view need to make the actual delete operation
  }

  void onFilterTextChanged(final String text) {
    _deadlineTimer?.cancel();
    _deadlineTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _filterText = text.toLowerCase();
        list = getList().where((final T instance) => isMatchingFilterText(instance)).toList();
      });
      _deadlineTimer = null;
    });
  }

  bool isMatchingFilterText(final T instance) {
    if (_filterText.isEmpty) {
      return true;
    }

    return getFieldsForTable().columnValueContainString(instance, _filterText);
  }

  void updateBottomContent(final int tab) {
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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: getPanelForTransactions(selectedItems),
        );
      default:
        return const Text('- empty -');
    }
  }

  void onRowTap(final BuildContext context, final int index) {
    if (isMobile()) {
      myShowDialog(
        context: context,
        title: 'getDetailPanelHeader(context, index, list[index]),',
        child: getPanelForDetails(<int>[index]),
      );
    } else {
      // This will cause a UI update and the bottom details will get rendered if its expanded
      if (index == -1) {
        selectedItems.value = [];
      } else {
        selectedItems.value = <int>[index];
      }

      // call this to persist the last selected item index
      saveLastUserActionOnThisView();
    }
  }

  Widget getDetailPanelHeader(final BuildContext context, final num index, final T item) {
    return Center(child: Text('${getClassNameSingular()} #${index + 1}'));
  }

  Widget getPanelForDetails(final List<int> indexOfItems) {
    final Fields<T> detailPanelFields = getFieldsForDetailsPanel();
    if (indexOfItems.isNotEmpty) {
      final int index = indexOfItems.first;
      if (isBetweenOrEqual(index, 0, list.length - 1)) {
        return SingleChildScrollView(
          key: Key(index.toString()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: detailPanelFields.getCellsForDetailsPanel(list[index]),
            ),
          ),
        );
      }
    }
    return const CenterMessage(message: 'No item selected.');
  }

  Widget getPanelForChart(final List<int> indices) {
    return const Text('No chart to display');
  }

  Widget getPanelForTransactions(final List<int> indices) {
    return const Text('the transactions');
  }

  void changeListSortOrder(final int columnNumber) {
    setState(() {
      if (columnNumber == _sortByFieldIndex) {
        // toggle order
        _sortAscending = !_sortAscending;
      } else {
        _sortByFieldIndex = columnNumber;
      }

      // Persist users choice
      saveLastUserActionOnThisView();
      onSort();
    });
  }

  void saveLastUserActionOnThisView() {
    // Persist users choice
    Settings().views[getClassNameSingular()] = <String, dynamic>{
      prefSortBy: _sortByFieldIndex,
      prefSortAscending: _sortAscending,
      prefSelectedListItemIndex: selectedItems.value.firstOrNull,
    };

    Settings().save();
  }

  SortIndicator getSortIndicated(final int columnNumber) {
    if (columnNumber == _sortByFieldIndex) {
      return _sortAscending ? SortIndicator.sortAscending : SortIndicator.sortDescending;
    }
    return SortIndicator.none;
  }

  List<String> getUniqueInstances(final Field<T, dynamic> columnToCustomerFilterOn) {
    final Set<String> set = <String>{}; // This is a Set()
    final List<T> list = getList();
    for (int i = 0; i < list.length; i++) {
      final String fieldValue = columnToCustomerFilterOn.valueFromInstance(list[i]).toString();
      set.add(fieldValue);
    }
    final List<String> uniqueValues = set.toList();
    uniqueValues.sort();
    return uniqueValues;
  }

  List<double> getMinMaxValues(final Field<T, dynamic> fieldDefinition) {
    double min = 0.0;
    double max = 0.0;
    final List<T> list = getList();
    for (int i = 0; i < list.length; i++) {
      final double fieldValue = fieldDefinition.valueFromInstance(list[i]) as double;
      if (min > fieldValue) {
        min = fieldValue;
      }
      if (max < fieldValue) {
        max = fieldValue;
      }
    }

    return <double>[min, max];
  }

  List<String> getMinMaxDates(final Field<T, dynamic> columnToCustomerFilterOn) {
    String min = '';
    String max = '';

    for (final item in getList()) {
      final String fieldValue = columnToCustomerFilterOn.valueFromInstance(item) as String;
      if (min.isEmpty || min.compareTo(fieldValue) == 1) {
        min = fieldValue;
      }
      if (max.isEmpty || max.compareTo(fieldValue) == -1) {
        max = fieldValue;
      }
    }

    return <String>[min, max];
  }

  void onCustomizeColumn(final Field<T, dynamic> fieldDefinition) {
    Widget content;

    switch (fieldDefinition.type) {
      case FieldType.amount:
        {
          final List<double> minMax = getMinMaxValues(fieldDefinition);
          content = SizedBox(
            height: 200,
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(Currency.getCurrencyText(minMax[0])),
                Text(Currency.getCurrencyText(minMax[1])),
              ],
            ),
          );
          break;
        }

      case FieldType.date:
        {
          final List<String> minMax = getMinMaxDates(fieldDefinition);
          content = SizedBox(
            height: 200,
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(minMax[0]),
                Text(minMax[1]),
              ],
            ),
          );
          break;
        }
      case FieldType.text:
      default:
        {
          listOfUniqueInstances = getUniqueInstances(fieldDefinition);

          content = Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Select All'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('UnSelect All'),
              ),
              SizedBox(
                height: 400,
                width: 300,
                child: ListView.builder(
                  itemCount: listOfUniqueInstances.length,
                  itemBuilder: (final BuildContext context, final int index) {
                    return CheckboxListTile(
                      title: Text(listOfUniqueInstances[index].toString()),
                      value: true,
                      onChanged: (final bool? isChecked) {},
                    );
                  },
                ),
              ),
            ],
          );
          break;
        }
    }

    myShowDialog(
      context: context,
      title: 'Column Filter',
      child: content,
      isEditable: false,
    );
  }
}
