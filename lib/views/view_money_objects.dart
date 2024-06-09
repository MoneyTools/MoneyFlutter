import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/preferences_helper.dart';
import 'package:money/views/action_buttons.dart';
import 'package:money/views/adaptive_view/adaptable_view_with_list.dart';
import 'package:money/views/adaptive_view/adaptive_list/column_filter_panel.dart';
import 'package:money/views/adaptive_view/adaptive_list/multiple_selection_context.dart';
import 'package:money/views/view_header.dart';
import 'package:money/views/view_transactions/money_object_card.dart';
import 'package:money/widgets/details_panel/info_panel.dart';
import 'package:money/widgets/details_panel/info_panel_views_enum.dart';
import 'package:money/widgets/dialog/dialog_button.dart';
import 'package:money/widgets/dialog/dialog_mutate_money_object.dart';
import 'package:money/widgets/message_box.dart';
import 'package:money/widgets/widgets.dart';

import '../models/fields/field_filter.dart';

class ViewForMoneyObjects extends StatefulWidget {
  const ViewForMoneyObjects({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewForMoneyObjectsState();
}

class ViewForMoneyObjectsState extends State<ViewForMoneyObjects> {
  // list management
  List<MoneyObject> list = <MoneyObject>[];
  final ValueNotifier<List<int>> _selectedItemsByUniqueId = ValueNotifier<List<int>>([]);
  Fields<MoneyObject> _fieldToDisplay = Fields<MoneyObject>();
  List<String> listOfUniqueString = <String>[];
  List<ValueSelection> listOfValueSelected = [];
  int _lastSelectedItemId = -1;
  int _sortByFieldIndex = 0;
  bool _sortAscending = true;

  // Multi selection support
  bool supportsMultiSelection = false;
  bool _isMultiSelectionOn = false;
  VoidCallback? onMultiSelect;

  VoidCallback? onAddItem;
  VoidCallback? onEditItems;
  Function(BuildContext, MoneyObject)? onMergeItem;
  VoidCallback? onDeleteItems;

  // detail panel
  Object? subViewSelectedItem;
  InfoPanelSubViewEnum _selectedBottomTabId = InfoPanelSubViewEnum.details;
  int _selectedCurrency = 0;

  // header
  String _filterByText = '';
  FieldFilters _filterByFieldsValue = FieldFilters();
  Timer? _deadlineTimer;
  Function? onAddTransaction;

  /// Derived class will override to customize the fields to display in the Adaptive Table
  Fields<MoneyObject> getFieldsForTable() {
    return Fields<MoneyObject>();
  }

  @override
  void initState() {
    super.initState();

    var all = getFieldsForTable();

    _fieldToDisplay = Fields<MoneyObject>();
    _fieldToDisplay.setDefinitions(all.definitions.where((element) => element.useAsColumn).toList());

    // restore last user choices for this view
    _sortByFieldIndex = PreferencesHelper().getInt(getPreferenceKey(settingKeySortBy)) ?? 0;
    _sortAscending = PreferencesHelper().getBool(getPreferenceKey(settingKeySortAscending)) ?? true;
    _lastSelectedItemId = PreferencesHelper().getInt(getPreferenceKey(settingKeySelectedListItemId)) ?? -1;

    final int subViewIndex = PreferencesHelper().getInt(getPreferenceKey(settingKeySelectedDetailsPanelTab)) ??
        InfoPanelSubViewEnum.details.index;

    _selectedBottomTabId = InfoPanelSubViewEnum.values[subViewIndex];

    // Filters

    // load text filter
    _filterByText = PreferencesHelper().getString(getPreferenceKey(settingKeyFilterText)) ?? '';

    // load the column filters
    _filterByFieldsValue =
        FieldFilters.fromList(PreferencesHelper().getStringList(getPreferenceKey(settingKeyFilterColumnsText)) ?? []);

    list = getList();

    /// restore selection of items
    setSelectedItem(_lastSelectedItemId);
  }

  String getPreferenceKey(final String suffix) {
    return getViewPreferenceId(getViewId(), suffix);
  }

  void onCopyListFromMainView() {
    copyToClipboardAndInformUser(context, MoneyObjects.getCsvFromList(list, forSerialization: false));
  }

  void onCopyListFromInfoPanel() {
    final listToCopy = getInfoTransactions();
    copyToClipboardAndInformUser(context, MoneyObjects.getCsvFromList(listToCopy, forSerialization: true));
  }

  List<Widget> getActionsForSelectedItems(final bool forInfoPanelTransactions) {
    List<Widget> widgets = [];

    /// Info panel header
    if (forInfoPanelTransactions) {
      if (_selectedBottomTabId == InfoPanelSubViewEnum.transactions) {
        /// Add Transactions
        if (onAddTransaction != null) {
          widgets.add(buildAddTransactionsButton(onAddTransaction!));
        }

        /// Copy Info List
        widgets.add(buildCopyButton(onCopyListFromInfoPanel));
      }
    }

    /// Main header
    else {
      /// only when there is one or more selection
      if (_selectedItemsByUniqueId.value.isNotEmpty) {
        ///  Edit
        widgets.add(
          buildEditButton(() {
            myShowDialogAndActionsForMoneyObjects(
              context: context,
              title: _selectedItemsByUniqueId.value.length == 1 ? getClassNameSingular() : getClassNamePlural(),
              moneyObjects: getSelectedItemsFromSelectedList(_selectedItemsByUniqueId.value),
            );
          }),
        );

        /// Delete
        widgets.add(
          buildDeleteButton(
            () {
              onUserRequestedToDelete(
                context,
                getSelectedItemsFromSelectedList(_selectedItemsByUniqueId.value),
              );
            },
          ),
        );

        /// Copy List
        widgets.add(buildCopyButton(onCopyListFromMainView));
      }
    }

    return widgets;
  }

  @override
  Widget build(final BuildContext context) {
    return buildViewContent(
      AdaptiveViewWithList(
        key: Key(list.length.toString()),
        top: buildHeader(),
        list: list,
        fieldDefinitions: _fieldToDisplay.definitions,
        filters: _filterByFieldsValue,
        selectedItemsByUniqueId: _selectedItemsByUniqueId,
        sortByFieldIndex: _sortByFieldIndex,
        sortAscending: _sortAscending,
        isMultiSelectionOn: _isMultiSelectionOn,
        onColumnHeaderTap: changeListSortOrder,
        onColumnHeaderLongPress: onCustomizeColumn,
        onSelectionChanged: (int _) {
          _selectedItemsByUniqueId.value = _selectedItemsByUniqueId.value.toList();
          saveLastUserChoicesOfView();
        },
        onItemTap: onItemTap,
        flexBottom: Settings().isDetailsPanelExpanded ? 1 : 0,
        bottom: InfoPanel(
          isExpanded: Settings().isDetailsPanelExpanded,
          onExpanded: (final bool isExpanded) {
            setState(() {
              Settings().isDetailsPanelExpanded = isExpanded;
              Settings().preferrenceSave();
            });
          },
          selectedItems: _selectedItemsByUniqueId,

          // SubView
          subPanelSelected: _selectedBottomTabId,
          subPanelSelectionChanged: updateBottomContent,
          subPanelContent: getInfoPanelContent,

          // Currency
          getCurrencyChoices: getCurrencyChoices,
          currencySelected: _selectedCurrency,
          currencySelectionChanged: (final int selected) {
            setState(() {
              _selectedCurrency = selected;
            });
          },

          /// Actions
          actionButtons: getActionsForSelectedItems,
        ),
      ),
    );
  }

  void onSelectAll(final bool selectAll) {
    setState(() {
      _selectedItemsByUniqueId.value.clear();
      if (selectAll) {
        for (final item in list) {
          _selectedItemsByUniqueId.value.add(item.uniqueId);
        }
      }
    });
  }

  void updateListAndSelect(final int uniqueId) {
    setState(() {
      clearSelection();
      list = getList();
      setSelectedItem(uniqueId);
    });
  }

  Widget buildViewContent(final Widget child) {
    return Container(
      color: getColorTheme(context).surface,
      child: child,
    );
  }

  Widget buildHeader([final Widget? child]) {
    ViewHeaderMultipleSelection? multipleSelectionOptions;
    if (supportsMultiSelection) {
      multipleSelectionOptions = ViewHeaderMultipleSelection(
        selectedItems: _selectedItemsByUniqueId,
        isMultiSelectionOn: _isMultiSelectionOn,
        onToggleMode: () {
          setState(() {
            _isMultiSelectionOn = !_isMultiSelectionOn;
            if (!_isMultiSelectionOn) {
              setSelectedItem(-1);
            }
          });
        },
      );
    }

    return ViewHeader(
      key: Key(_selectedItemsByUniqueId.value.length.toString()),
      title: getClassNamePlural(),
      itemCount: list.length,
      selectedItems: _selectedItemsByUniqueId,
      description: getDescription(),
      multipleSelection: multipleSelectionOptions,
      getActionButtonsForSelectedItems: getActionsForSelectedItems,
      onAddMoneyObject: onAddItem,
      onMergeMoneyObject: onMergeItem == null
          ? null
          : () {
              onMergeItem!(context, getSelectedItemsFromSelectedList(_selectedItemsByUniqueId.value).first);
            },
      onEditMoneyObject: onEditItems,
      onDeleteMoneyObject: onDeleteItems,
      filterText: _filterByText,
      onFilterChanged: onFilterTextChanged,
      child: child,
    );
  }

  String getClassNameSingular() {
    return 'Item';
  }

  String getClassNamePlural() {
    return 'Items';
  }

  String getDescription() {
    return 'Default list of items';
  }

  /// must override this in each view
  String getViewId() {
    return '_id_';
  }

  String getCurrency() {
    // default currency for this view
    return Constants.defaultCurrency;
  }

  List<MoneyObject> getList({bool includeDeleted = false, bool applyFilter = true}) {
    return <MoneyObject>[];
  }

  void clearSelection() {
    _selectedItemsByUniqueId.value = [];
    saveLastUserChoicesOfView();
  }

  void onSort() {
    if (isIndexInRange(_fieldToDisplay.definitions, _sortByFieldIndex)) {
      final Field<dynamic> fieldDefinition = _fieldToDisplay.definitions[_sortByFieldIndex];
      if (fieldDefinition.sort == null) {
        // No sorting function found, fallback to String sorting
        list.sort((final MoneyObject a, final MoneyObject b) {
          return sortByString(
            fieldDefinition.getValueForDisplay(a).toString(),
            fieldDefinition.getValueForDisplay(b).toString(),
            _sortAscending,
          );
        });
      } else {
        list.sort((final MoneyObject a, final MoneyObject b) {
          return fieldDefinition.sort!(a, b, _sortAscending);
        });
      }
    }
  }

  void onUserRequestToEdit(final BuildContext context, final List<MoneyObject> moneyObjects) {
    myShowDialogAndActionsForMoneyObjects(
      context: context,
      title: getSingularPluralText('Edit', moneyObjects.length, getClassNameSingular(), getClassNamePlural()),
      moneyObjects: moneyObjects,
    );
  }

  void onUserRequestedToDelete(final BuildContext context, final List<MoneyObject> moneyObjects) {
    if (moneyObjects.isEmpty) {
      messageBox(context, 'No items to delete');
      return;
    }

    final String nameSingular = getClassNameSingular();
    final String namePlural = getClassNamePlural();

    final String title = getSingularPluralText('Delete', moneyObjects.length, nameSingular, namePlural);

    final String question = moneyObjects.length == 1
        ? 'Are you sure you want to delete this $nameSingular?'
        : 'Are you sure you want to delete the ${moneyObjects.length} selected $namePlural?';

    adaptiveScreenSizeDialog(
      context: context,
      title: title,
      captionForClose: null, // this will hide the close button
      child: DeleteConfirmationDialog(
        question: question,
        content: moneyObjects.length == 1
            ? Column(children: moneyObjects.first.buildWidgets(onEdit: null, compact: true))
            : Center(
                child:
                    Text('${getIntAsText(moneyObjects.length)} $namePlural', style: getTextTheme(context).displaySmall),
              ),
        onConfirm: () {
          Data().deleteItems(moneyObjects);
        },
      ),
    );
  }

  void onFilterTextChanged(final String text) {
    _deadlineTimer?.cancel();
    _deadlineTimer = Timer(const Duration(milliseconds: 500), () {
      _deadlineTimer = null;
      setState(() {
        _filterByText = text.toLowerCase();
        saveLastUserChoicesOfView();
        list = getList();
      });
    });
  }

  bool isMatchingFilters(final MoneyObject instance) {
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

  void updateBottomContent(final InfoPanelSubViewEnum tab) {
    setState(() {
      _selectedBottomTabId = tab;
      saveLastUserChoicesOfView();
    });
  }

  Widget getInfoPanelContent(final InfoPanelSubViewEnum subViewId, final List<int> selectedIds) {
    switch (subViewId) {
      /// Details
      case InfoPanelSubViewEnum.details:
        return getInfoPanelViewDetails(selectedIds: selectedIds, isReadOnly: false);

      /// Chart
      case InfoPanelSubViewEnum.chart:
        return getInfoPanelViewChart(selectedIds: selectedIds, showAsNativeCurrency: _selectedCurrency == 0);

      /// Transactions
      case InfoPanelSubViewEnum.transactions:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: getInfoPanelViewTransactions(selectedIds: selectedIds, showAsNativeCurrency: _selectedCurrency == 0),
        );
      default:
        return const Text('- empty -');
    }
  }

  /// Override in your view
  List<String> getCurrencyChoices(final InfoPanelSubViewEnum subViewId, final List<int> selectedItems) {
    switch (subViewId) {
      case InfoPanelSubViewEnum.details:
      case InfoPanelSubViewEnum.chart:
      case InfoPanelSubViewEnum.transactions:
      default:
        return [];
    }
  }

  void setSelectedItem(final int uniqueId) {
    // This will cause a UI update and the bottom details will get rendered if its expanded
    setState(() {
      //
      if (uniqueId == -1) {
        // clear
        _selectedItemsByUniqueId.value.clear();
      } else {
        if (!_selectedItemsByUniqueId.value.contains(uniqueId)) {
          // _selectedItemsByUniqueId.value = <int>[uniqueId];
          _selectedItemsByUniqueId.value.add(uniqueId);
        }
      }

      // persist the last selected item index
      PreferencesHelper().setInt(getPreferenceKey(settingKeySelectedListItemId), _lastSelectedItemId);
    });
  }

  void onItemTap(final BuildContext context, final int uniqueId) {
    if (isMobile()) {
      adaptiveScreenSizeDialog(
        context: context,
        title: '${getClassNameSingular()} #${uniqueId + 1}',
        actionButtons: [],
        child: getInfoPanelViewDetails(selectedIds: <int>[uniqueId], isReadOnly: true),
      );
    }
  }

  MoneyObject? getFirstSelectedItem() {
    if (_selectedItemsByUniqueId.value.isNotEmpty) {
      final firstId = _selectedItemsByUniqueId.value.firstOrNull;
      if (firstId != null) {
        return list.firstWhereOrNull((moneyObject) => moneyObject.uniqueId == firstId);
      }
    }
    return null;
  }

  MoneyObject? getFirstSelectedItemFromSelectedList(final List<int> selectedList) {
    return getMoneyObjectFromFirstSelectedId<MoneyObject>(selectedList, list);
  }

  List<MoneyObject> getSelectedItemsFromSelectedList(final List<int> selectedList) {
    if (selectedList.isEmpty) {
      return [];
    }

    final Set<int> selectedIds = selectedList.toSet();
    return list.where((moneyObject) => selectedIds.contains(moneyObject.uniqueId)).toList();
  }

  int? getUniqueIdOfFirstSelectedItem() {
    return _selectedItemsByUniqueId.value.firstOrNull;
  }

  Widget getInfoPanelHeader(final BuildContext context, final num index, final MoneyObject item) {
    return Center(child: Text('${getClassNameSingular()} #${index + 1}'));
  }

  Widget getInfoPanelViewDetails({required final List<int> selectedIds, required final bool isReadOnly}) {
    if (selectedIds.length > 1) {
      return CenterMessage(message: 'Multiple selection.(${selectedIds.length})');
    }

    final MoneyObject? moneyObject = findObjectById(selectedIds.firstOrNull, list);

    if (moneyObject == null) {
      return const CenterMessage(message: 'No item selected.');
    }

    return SingleChildScrollView(
      key: Key('detail_panel_${moneyObject.uniqueId}'),
      child: MoneyObjectCard(
        title: getClassNameSingular(),
        moneyObject: moneyObject,
        onMergeWith: onMergeItem,
        onEdit: onUserRequestToEdit,
        onDelete: onUserRequestedToDelete,
      ),
    );
  }

  Widget getInfoPanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return const Center(child: Text('No chart to display'));
  }

  Widget getInfoPanelViewTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return const Center(child: Text('No transactions'));
  }

  List<MoneyObject> getInfoTransactions() {
    return [];
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
      saveLastUserChoicesOfView();
    });
  }

  void saveLastUserChoicesOfView() {
    // Persist users choice
    PreferencesHelper().setInt(getPreferenceKey(settingKeySortBy), _sortByFieldIndex);
    PreferencesHelper().setBool(getPreferenceKey(settingKeySortAscending), _sortAscending);
    PreferencesHelper().setInt(getPreferenceKey(settingKeySelectedListItemId), getUniqueIdOfFirstSelectedItem() ?? -1);
    PreferencesHelper().setInt(getPreferenceKey(settingKeySelectedDetailsPanelTab), _selectedBottomTabId.index);
    PreferencesHelper().setString(getPreferenceKey(settingKeyFilterText), _filterByText);
    PreferencesHelper()
        .setStringList(getPreferenceKey(settingKeyFilterColumnsText), _filterByFieldsValue.toStringList());
  }

  /// Compile the list of single data value for a column/field definition
  List<String> getUniqueInstances(final Field<dynamic> columnToCustomerFilterOn) {
    final Set<String> set = <String>{}; // This is a Set()
    final List<MoneyObject> list = getList(applyFilter: false);
    for (final moneyObject in list) {
      String fieldValue = columnToCustomerFilterOn.getValueForDisplay(moneyObject).toString();
      set.add(fieldValue);
    }
    return set.toList();
  }

  /// Compile the list of single date value for a column/field definition
  List<String> getUniqueInstancesOfDates(final Field<dynamic> columnToCustomerFilterOn) {
    final Set<String> set = <String>{}; // This is a Set()
    final List<MoneyObject> list = getList(applyFilter: false);
    for (final moneyObject in list) {
      final String fieldValue = dateToString(columnToCustomerFilterOn.getValueForDisplay(moneyObject));
      set.add(fieldValue);
    }
    final List<String> uniqueValues = set.toList();
    uniqueValues.sort();
    return uniqueValues;
  }

  /// Compile the list of single date value for a column/field definition
  List<String> getUniqueInstancesOfNumbers(final Field<dynamic> columnToCustomerFilterOn) {
    final Set<String> set = <String>{}; // This is a Set()
    final List<MoneyObject> list = getList(applyFilter: false);
    for (final moneyObject in list) {
      final String fieldValue = formatDoubleTrimZeros(columnToCustomerFilterOn.getValueForDisplay(moneyObject));
      set.add(fieldValue);
    }
    final List<String> uniqueValues = set.toList();
    uniqueValues.sort((a, b) => compareStringsAsNumbers(a, b));
    return uniqueValues;
  }

  void onCustomizeColumn(final Field<dynamic> fieldDefinition) {
    Widget content;
    listOfValueSelected.clear();

    switch (fieldDefinition.type) {
      case FieldType.quantity:
        {
          listOfUniqueString = getUniqueInstancesOfNumbers(fieldDefinition);

          for (final item in listOfUniqueString) {
            listOfValueSelected.add(ValueSelection(name: item, isSelected: true));
          }

          content = ColumnFilterPanel(
            listOfUniqueInstances: listOfValueSelected,
            textAlign: TextAlign.right,
          );
        }

      case FieldType.date:
        {
          listOfUniqueString = getUniqueInstancesOfDates(fieldDefinition);

          for (final item in listOfUniqueString) {
            listOfValueSelected.add(ValueSelection(name: item, isSelected: true));
          }

          content = ColumnFilterPanel(
            listOfUniqueInstances: listOfValueSelected,
            textAlign: TextAlign.left,
          );
        }

      case FieldType.text:
      default:
        {
          listOfUniqueString = getUniqueInstances(fieldDefinition);

          if (fieldDefinition.type == FieldType.amount) {
            listOfUniqueString.sort((a, b) => compareStringsAsAmount(a, b));
          } else {
            listOfUniqueString.sort();
          }

          for (final item in listOfUniqueString) {
            listOfValueSelected.add(ValueSelection(name: item, isSelected: true));
          }

          content = ColumnFilterPanel(
            listOfUniqueInstances: listOfValueSelected,
            textAlign: fieldDefinition.type == FieldType.amount ? TextAlign.right : TextAlign.left,
          );
        }
    }

    adaptiveScreenSizeDialog(
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

              if (_filterByFieldsValue.length == listOfValueSelected.length) {
                // all unique values are selected so clear the column filter;
                _filterByFieldsValue.clear();
              }

              saveLastUserChoicesOfView();

              list = getList();
            });
          },
        )
      ],
    );
  }
}
