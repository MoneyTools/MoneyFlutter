import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_header.dart';
import 'package:money/views/view_transactions/money_object_card.dart';
import 'package:money/widgets/details_panel/details_panel.dart';
import 'package:money/widgets/details_panel/dialog_mutate_money_object.dart';
import 'package:money/widgets/dialog_button.dart';
import 'package:money/widgets/list_view/column_filter_panel.dart';
import 'package:money/widgets/list_view/list_view.dart';
import 'package:money/widgets/widgets.dart';

import '../models/fields/field_filter.dart';

class ViewWidget extends StatefulWidget {
  const ViewWidget({super.key});

  @override
  State<ViewWidget> createState() => ViewWidgetState();
}

class ViewWidgetState extends State<ViewWidget> {
  // list management
  List<MoneyObject> list = <MoneyObject>[];
  final ValueNotifier<List<int>> _selectedItemsByUniqueId = ValueNotifier<List<int>>(<int>[]);
  Fields<MoneyObject> _fieldToDisplay = Fields<MoneyObject>(definitions: <Field<dynamic>>[]);
  List<String> listOfUniqueString = <String>[];
  List<ValueSelection> listOfValueSelected = [];
  int _lastSelectedItemId = -1;
  int _sortByFieldIndex = 0;
  bool _sortAscending = true;
  VoidCallback? onAddNewEntry;

  // detail panel
  Object? subViewSelectedItem;
  SubViews _selectedBottomTabId = SubViews.details;
  int _selectedCurrency = 0;

  // header
  String _filterByText = '';
  final List<FieldFilter> _filterByFieldsValue = [];
  Timer? _deadlineTimer;
  Function? onAddTransaction;

  /// Derived class will override to customize the fields to display in the Adaptive Table
  Fields<MoneyObject> getFieldsForTable() {
    return Fields<MoneyObject>(definitions: []);
  }

  @override
  void initState() {
    super.initState();

    var all = getFieldsForTable();
    _fieldToDisplay =
        Fields<MoneyObject>(definitions: all.definitions.where((element) => element.useAsColumn).toList());

    final MyJson? viewSetting = Settings().views[getClassNameSingular()];
    if (viewSetting != null) {
      _sortByFieldIndex = viewSetting.getInt(prefSortBy, 0);
      _sortAscending = viewSetting.getBool(prefSortAscending, true);
      _lastSelectedItemId = viewSetting.getInt(prefSelectedListItemId, -1);
      final int subViewIndex = viewSetting.getInt(prefSelectedDetailsPanelTab, SubViews.details.index);
      _selectedBottomTabId = SubViews.values[subViewIndex];
    }

    list = getList();

    onSort();

    /// restore selection of items
    setSelectedItem(_lastSelectedItemId);
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
              MyListItemHeader<MoneyObject>(
                columns: _fieldToDisplay.definitions,
                sortByColumn: _sortByFieldIndex,
                sortAscending: _sortAscending,
                onTap: changeListSortOrder,
                onLongPress: onCustomizeColumn,
              ),

            // Table rows
            Expanded(
              flex: 1,
              child: MyListView<MoneyObject>(
                key: Key('MyListView_selected_id_${getUniqueIdOfFirstSelectedItem()}'),
                list: list,
                selectedItemIds: _selectedItemsByUniqueId,
                fields: _fieldToDisplay,
                asColumnView: useColumns,
                onTap: onItemSelected,
                unSelectable: true,
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
                    Settings().store();
                  });
                },
                selectedItems: _selectedItemsByUniqueId,

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
                onActionAddTransaction: onAddTransaction,
                onActionEdit: () {
                  showDialogAndActionsForMoneyObject(
                      context: context, moneyObject: getFirstSelectedItem() as MoneyObject);
                },
                onActionDelete: () {
                  onDeleteRequestedByUser(context, getFirstSelectedItem() as MoneyObject);
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
      color: getColorTheme(context).background,
      child: child,
    );
  }

  Widget buildHeader([final Widget? child]) {
    return ViewHeader(
      title: getClassNamePlural(),
      count: numValueOrDefault(list.length),
      description: getDescription(),
      onAddNewEntry: onAddNewEntry,
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

  List<MoneyObject> getList([bool includeDeleted = false]) {
    return <MoneyObject>[];
  }

  void clearSelection() {
    //_selectedItemsByUniqueId.value.clear();
  }

  void onSort() {
    if (_fieldToDisplay.definitions.isNotEmpty) {
      if (isBetween(_sortByFieldIndex, -1, _fieldToDisplay.definitions.length)) {
        final Field<dynamic> fieldDefinition = _fieldToDisplay.definitions[_sortByFieldIndex];
        if (fieldDefinition.sort == null) {
          list.sort((final MoneyObject a, final MoneyObject b) {
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
          list.sort((final MoneyObject a, final MoneyObject b) {
            return fieldDefinition.sort!(a, b, _sortAscending);
          });
        }
      }
    }
  }

  void onDeleteRequestedByUser(final BuildContext context, final MoneyObject? myMoneyObjectInstance) {
    if (myMoneyObjectInstance != null) {
      showDialog(
        context: context,
        builder: (final BuildContext context) {
          return Center(
            child: DeleteConfirmationDialog(
              title: 'Delete ${getClassNameSingular()}',
              question: 'Are you sure you want to delete this ${getClassNameSingular()}?',
              content: Column(
                children: myMoneyObjectInstance.buildWidgets(onEdit: null, compact: true),
              ),
              onConfirm: () {
                onDeleteConfirmedByUser(myMoneyObjectInstance);
              },
            ),
          );
        },
      );
    }
  }

  void onDeleteConfirmedByUser(final MoneyObject instance) {
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

  bool isMatchingFilterText(final MoneyObject instance) {
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

  void updateBottomContent(final SubViews tab) {
    setState(() {
      _selectedBottomTabId = tab;
      saveLastUserActionOnThisView();
    });
  }

  Widget getDetailPanelContent(final SubViews subViewId, final List<int> selectedIds) {
    switch (subViewId) {
      case SubViews.details:
        return getPanelForDetails(selectedIds: selectedIds, isReadOnly: false);
      case SubViews.chart:
        return getPanelForChart(selectedIds);
      case SubViews.transactions:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: getPanelForTransactions(selectedIds: selectedIds, showAsNativeCurrency: _selectedCurrency == 0),
        );
      default:
        return const Text('- empty -');
    }
  }

  /// refresh the [this.list] by apply the filters
  void updateList() {
    list = getList().where((final MoneyObject instance) => isMatchingFilterText(instance)).toList();
  }

  /// Override in your view
  List<String> getCurrencyChoices(final SubViews subViewId, final List<int> selectedItems) {
    switch (subViewId) {
      case SubViews.details:
      case SubViews.chart:
      case SubViews.transactions:
      default:
        return [];
    }
  }

  void setSelectedItem(final int uniqueId) {
    // This will cause a UI update and the bottom details will get rendered if its expanded
    if (uniqueId == -1) {
      _selectedItemsByUniqueId.value = [];
    } else {
      _selectedItemsByUniqueId.value = <int>[uniqueId];
    }

    // call this to persist the last selected item index
    saveLastUserActionOnThisView();
  }

  void onItemSelected(final BuildContext context, final int uniqueId) {
    if (isMobile()) {
      myShowDialog(
        context: context,
        title: '${getClassNameSingular()} #${uniqueId + 1}',
        actionButtons: [],
        child: getPanelForDetails(selectedIds: <int>[uniqueId], isReadOnly: true),
      );
    } else {
      setSelectedItem(uniqueId);
    }
  }

  MoneyObject? getFirstSelectedItem() {
    return getFirstSelectedItemFromSelectedList(_selectedItemsByUniqueId.value);
  }

  MoneyObject? getFirstSelectedItemFromSelectedList(final List<int> selectedList) {
    return getMoneyObjectFromFirstSelectedId<MoneyObject>(selectedList, list);
  }

  int? getUniqueIdOfFirstSelectedItem() {
    return _selectedItemsByUniqueId.value.firstOrNull;
  }

  Widget getDetailPanelHeader(final BuildContext context, final num index, final MoneyObject item) {
    return Center(child: Text('${getClassNameSingular()} #${index + 1}'));
  }

  Widget getPanelForDetails({required final List<int> selectedIds, required final bool isReadOnly}) {
    final MoneyObject? moneyObject = findObjectById(selectedIds.firstOrNull, list);

    if (moneyObject == null) {
      return const CenterMessage(message: 'No item selected.');
    }

    return SingleChildScrollView(
      key: Key('detail_panel_${moneyObject.uniqueId}'),
      child: MoneyObjectCard(title: '', moneyObject: moneyObject),
    );
  }

  Widget getPanelForChart(final List<int> indices) {
    return const Center(child: Text('No chart to display'));
  }

  Widget getPanelForTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return const Center(child: Text('No transactions'));
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
      prefSelectedListItemId: getUniqueIdOfFirstSelectedItem(),
      prefSelectedDetailsPanelTab: _selectedBottomTabId.index,
    };

    Settings().store();
  }

  SortIndicator getSortIndicated(final int columnNumber) {
    if (columnNumber == _sortByFieldIndex) {
      return _sortAscending ? SortIndicator.sortAscending : SortIndicator.sortDescending;
    }
    return SortIndicator.none;
  }

  List<String> getUniqueInstances(final Field<dynamic> columnToCustomerFilterOn) {
    final Set<String> set = <String>{}; // This is a Set()
    final List<MoneyObject> list = getList();
    for (int i = 0; i < list.length; i++) {
      final String fieldValue = columnToCustomerFilterOn.valueFromInstance(list[i]).toString();
      set.add(fieldValue);
    }
    final List<String> uniqueValues = set.toList();
    uniqueValues.sort();
    return uniqueValues;
  }

  List<double> getMinMaxValues(final Field<dynamic> fieldDefinition) {
    double min = 0.0;
    double max = 0.0;
    final List<MoneyObject> list = getList();
    for (int i = 0; i < list.length; i++) {
      dynamic fieldValue = fieldDefinition.valueFromInstance(list[i]);

      if (fieldDefinition.type == FieldType.amount && fieldValue is String) {
        fieldValue = attemptToGetDoubleFromText(fieldValue) ?? 0;
      }

      if (min > fieldValue) {
        min = fieldValue;
      }
      if (max < fieldValue) {
        max = fieldValue;
      }
    }

    return <double>[min, max];
  }

  List<String> getMinMaxDates(final Field<dynamic> columnToCustomerFilterOn) {
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

  void onCustomizeColumn(final Field<dynamic> fieldDefinition) {
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
                Text(Currency.getAmountAsStringUsingCurrency(minMax[0])),
                Text(Currency.getAmountAsStringUsingCurrency(minMax[1])),
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
