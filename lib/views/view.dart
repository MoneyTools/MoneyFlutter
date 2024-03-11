import 'dart:async';
import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/widgets/dialog_button.dart';
import 'package:money/widgets/list_view/column_filter_panel.dart';
import 'package:money/widgets/details_panel/details_panel_fields.dart';
import 'package:money/widgets/widgets.dart';
import 'package:money/views/view_header.dart';
import 'package:money/widgets/details_panel/details_panel.dart';
import 'package:money/widgets/list_view/list_view.dart';

import '../models/fields/field_filter.dart';

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
  List<String> listOfUniqueString = <String>[];
  List<ValueSelection> listOfValueSelected = [];
  int _lastSelectedItemIndex = 0;
  int _sortByFieldIndex = 0;
  bool _sortAscending = true;

  // detail panel
  Object? subViewSelectedItem;
  int _selectedBottomTabId = 0;
  int _selectedCurrency = 0;

  // header
  String _filterByText = '';
  final List<FieldFilter> _filterByFieldsValue = [];
  Timer? _deadlineTimer;

  /// Derived class will override to customize the fields to display in the Adaptive Table
  Fields<T> getFieldsForTable() {
    return Fields<T>(definitions: getFieldsForClass<T>().where((element) => element.useAsColumn).toList());
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
      _selectedBottomTabId = viewSetting.getInt(prefSelectedDetailsPanelTab, 0);
    }

    list = getList();

    onSort();

    /// restore selection of items
    if (_lastSelectedItemIndex >= 0 && _lastSelectedItemIndex < list.length) {
      // index is valid
    } else {
      _lastSelectedItemIndex = 0;
    }
    setSelectedItem(_lastSelectedItemIndex);
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
              child: MyListView<T>(
                list: list,
                selectedItems: selectedItems,
                fields: _fieldToDisplay,
                asColumnView: useColumns,
                onTap: onItemSelected,
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
                selectedItems: selectedItems,

                // SubView
                subPanelSelected: _selectedBottomTabId,
                subPanelSelectionChanged: updateBottomContent,
                subPanelContent: getDetailPanelContent,

                // Currency
                getCurrencyChoices: getCurrencyChoices,
                currencySelected: _selectedCurrency,
                currencySelectionChanged: (final int selected) {
                  setState(() {
                    _selectedCurrency = selected;
                  });
                },

                // Actions
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

  String getCurrency() {
    // default currency for this view
    return Constants.defaultCurrency;
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
        return Center(
          child: DeleteConfirmationDialog(
            title: 'Delete ${getClassNameSingular()}',
            question: 'Are you sure you want to delete this ${getClassNameSingular()}?',
            content: Column(
              children: getFieldsForTable().getListOfFieldNameAndValuePairAsWidget(list[index]),
            ),
            onConfirm: () {
              onDeleteConfirmedByUser(list[index]);
            },
          ),
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
        _filterByText = text.toLowerCase();
        updateList();
      });
      _deadlineTimer = null;
    });
  }

  bool isMatchingFilterText(final T instance) {
    if (_filterByText.isEmpty && _filterByFieldsValue.isEmpty) {
      // nothing to filter by
      return true;
    }

    // apply filtering
    return getFieldsForTable().applyFilters(
      instance,
      _filterByText,
      _filterByFieldsValue,
    );
  }

  void updateBottomContent(final int tab) {
    setState(() {
      _selectedBottomTabId = tab;
      saveLastUserActionOnThisView();
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
          child: getPanelForTransactions(selectedItems: selectedItems, showAsNativeCurrency: _selectedCurrency == 0),
        );
      default:
        return const Text('- empty -');
    }
  }

  /// refresh the [this.list] by apply the filters
  void updateList() {
    list = getList().where((final T instance) => isMatchingFilterText(instance)).toList();
  }

  /// Override in your view
  List<String> getCurrencyChoices(final int subViewId, final List<int> selectedItems) {
    switch (subViewId) {
      case 0:
      case 1:
      case 2:
      default:
        return [];
    }
  }

  void setSelectedItem(final int index) {
    // This will cause a UI update and the bottom details will get rendered if its expanded
    if (index == -1) {
      selectedItems.value = [];
    } else {
      selectedItems.value = <int>[index];
    }

    // call this to persist the last selected item index
    saveLastUserActionOnThisView();
  }

  void onItemSelected(final BuildContext context, final int index) {
    if (isMobile()) {
      myShowDialog(
        context: context,
        title: 'getDetailPanelHeader(context, index, list[index]),',
        actionButtons: [],
        child: getPanelForDetails(<int>[index]),
      );
    } else {
      setSelectedItem(index);
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
          child: DetailsPanelFields(
            children: detailPanelFields.getCellsForDetailsPanel(
              list[index],
              () {
                setState(() {
                  /// update panel
                  Data().notifyTransactionChange(
                    MutationType.changed,
                    list[index] as MoneyObject,
                  );
                });
              },
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

  Widget getPanelForTransactions({
    required final List<int> selectedItems,
    required final bool showAsNativeCurrency,
  }) {
    return const Text('No transactions');
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
      prefSelectedDetailsPanelTab: _selectedBottomTabId,
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
        }
      case FieldType.text:
      default:
        {
          listOfUniqueString = getUniqueInstances(fieldDefinition);
          listOfValueSelected.clear();
          for (final item in listOfUniqueString) {
            listOfValueSelected.add(ValueSelection(name: item, isSelected: true));
          }
          content = ColumnFilterPanel(listOfUniqueInstances: listOfValueSelected);
        }
    }

    myShowDialog(
      context: context,
      title: 'Column Filter (${fieldDefinition.name})',
      child: content,
      actionButtons: [
        DialogActionButton(
          text: 'Apply',
          onPressed: () {
            Navigator.of(context).pop(false);
            setState(() {
              _filterByFieldsValue.clear();
              for (final value in listOfValueSelected) {
                if (value.isSelected) {
                  FieldFilter fieldFilter = FieldFilter(
                    fieldName: fieldDefinition.name,
                    filterTextInLowerCase: value.name,
                  );
                  _filterByFieldsValue.add(fieldFilter);
                }
              }
              updateList();
            });
          },
        )
      ],
    );
  }
}
