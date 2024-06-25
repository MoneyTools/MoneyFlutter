import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/fields/field_filter.dart';
import 'package:money/app/data/models/fields/fields.dart';
import 'package:money/app/data/models/money_objects/categories/category.dart';
import 'package:money/app/data/models/money_objects/currencies/currency.dart';
import 'package:money/app/data/models/money_objects/money_object.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/controller/general_controller.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/app/modules/home/views/view_categories/merge_categories.dart';
import 'package:money/app/modules/home/views/view_money_objects.dart';
import 'package:money/app/core/widgets/center_message.dart';
import 'package:money/app/core/widgets/chart.dart';
import 'package:money/app/core/widgets/columns/footer_widgets.dart';
import 'package:money/app/core/widgets/dialog/dialog.dart';
import 'package:money/app/core/widgets/dialog/dialog_button.dart';
import 'package:money/app/core/widgets/three_part_label.dart';

part 'view_categories_details_panels.dart';

class ViewCategories extends ViewForMoneyObjects {
  const ViewCategories({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewCategoriesState();
}

class ViewCategoriesState extends ViewForMoneyObjectsState {
  ViewCategoriesState() {
    viewId = ViewId.viewCategories;
    onAddItem = () {
      // add a new Account
      final newItem = Data().categories.addNewCategory('New Category');
      updateListAndSelect(newItem.uniqueId);
    };
  }

  final List<bool> _selectedPivot = <bool>[false, false, false, false, false, true];
  final List<Widget> _pivots = <Widget>[];

  // Footer related
  int _footerCountTransactions = 0;
  int _footerCountTransactionsRollUp = 0;
  double _footerSumBalance = 0.00;
  double _footerSumBalanceRollUp = 0.00;

  @override
  void initState() {
    super.initState();

    _pivots.add(ThreePartLabel(
        text1: 'None',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(_getTotalBalanceOfAccounts(<CategoryType>[CategoryType.none]))));
    _pivots.add(ThreePartLabel(
        text1: 'Expense',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(
            _getTotalBalanceOfAccounts(<CategoryType>[CategoryType.expense, CategoryType.recurringExpense]))));
    _pivots.add(ThreePartLabel(
        text1: 'Income',
        small: true,
        isVertical: true,
        text2:
            Currency.getAmountAsStringUsingCurrency(_getTotalBalanceOfAccounts(<CategoryType>[CategoryType.income]))));
    _pivots.add(ThreePartLabel(
        text1: 'Saving',
        small: true,
        isVertical: true,
        text2:
            Currency.getAmountAsStringUsingCurrency(_getTotalBalanceOfAccounts(<CategoryType>[CategoryType.saving]))));
    _pivots.add(ThreePartLabel(
        text1: 'Investment',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(
            _getTotalBalanceOfAccounts(<CategoryType>[CategoryType.investment]))));
    _pivots.add(ThreePartLabel(
        text1: 'All',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(_getTotalBalanceOfAccounts(<CategoryType>[]))));
  }

  @override
  String getClassNamePlural() {
    return 'Categories';
  }

  @override
  String getClassNameSingular() {
    return 'Category';
  }

  @override
  String getDescription() {
    return 'Classification of your money transactions.';
  }

  @override
  String getViewId() {
    return Data().categories.getTypeName();
  }

  @override
  Widget buildHeader([final Widget? child]) {
    return super.buildHeader(_buildToggles());
  }

  /// add more top leve action buttons
  @override
  List<Widget> getActionsForSelectedItems(final bool forInfoPanelTransactions) {
    final list = super.getActionsForSelectedItems(forInfoPanelTransactions);
    if (!forInfoPanelTransactions) {
      // Add a new Category
      list.insert(
        0,
        buildAddItemButton(() {
          // add a new Category
          final newItem = Data().categories.addNewTopLevelCategory();
          updateListAndSelect(newItem.uniqueId);
        }, 'Add new category'),
      );

      /// Merge
      final MoneyObject? moneyObject = getFirstSelectedItem();
      if (moneyObject != null) {
        list.add(
          buildMergeButton(
            () {
              // let the user pick another Category and move the transactions of the current selected Category to the destination
              adaptiveScreenSizeDialog(
                  context: context,
                  title: 'Move Category',
                  captionForClose: 'Cancel', // this will hide the close button
                  child: MergeCategoriesTransactionsDialog(categoryToMove: getFirstSelectedItem() as Category));
            },
          ),
        );
      }

      // this can go last
      if (getFirstSelectedItem() != null) {
        list.add(
          buildJumpToButton(
            [
              InternalViewSwitching(
                ViewId.viewTransactions.getIconData(),
                'Switch to Transactions',
                () {
                  final Category? category = getFirstSelectedItem() as Category?;
                  if (category != null) {
                    // Prepare the Transaction view to show only the selected account
                    FieldFilters filterByAccount = FieldFilters();
                    filterByAccount.add(FieldFilter(
                        fieldName: Constants.viewTransactionFieldnameCategory,
                        filterTextInLowerCase: category.name.value.toLowerCase()));

                    GeneralController().getPref().setStringList(
                          ViewId.viewTransactions.getViewPreferenceId(settingKeyFilterColumnsText),
                          filterByAccount.toStringList(),
                        );

                    // Switch view
                    GeneralController().selectedView = ViewId.viewTransactions;
                  }
                },
              ),
            ],
          ),
        );
      }
    }
    return list;
  }

  @override
  Fields<Category> getFieldsForTable() {
    return Category.fields ?? Fields<Category>();
  }

  @override
  Widget? getColumnFooterWidget(final Field field) {
    switch (field.name) {
      case '#T':
        return getFooterForInt(_footerCountTransactions);
      case '#T~':
        return getFooterForInt(_footerCountTransactionsRollUp);
      case 'Sum':
        return getFooterForAmount(_footerSumBalance);
      case 'Sum~':
        return getFooterForAmount(_footerSumBalanceRollUp);
      default:
        return null;
    }
  }

  @override
  List<Category> getList({bool includeDeleted = false, bool applyFilter = true}) {
    final List<CategoryType> filterType = _getSelectedCategoryType();
    final list = Data()
        .categories
        .iterableList(includeDeleted: includeDeleted)
        .where((final Category instance) =>
            (filterType.isEmpty || filterType.contains(instance.type.value)) &&
            (applyFilter == false || isMatchingFilters(instance)))
        .toList();

    _footerCountTransactions = 0;
    _footerCountTransactionsRollUp = 0;

    _footerSumBalance = 0.00;
    _footerSumBalanceRollUp = 0.00;

    for (final item in list) {
      _footerCountTransactions += item.transactionCount.value.toInt();
      _footerCountTransactionsRollUp += item.transactionCountRollup.value.toInt();

      _footerSumBalance += (item.sum.getValueForDisplay(item) as MoneyModel).toDouble();
      _footerSumBalanceRollUp += (item.sumRollup.getValueForDisplay(item) as MoneyModel).toDouble();
    }
    return list;
  }

  @override
  Widget getInfoPanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForChart(selectedIds: selectedIds, showAsNativeCurrency: showAsNativeCurrency);
  }

  @override
  Widget getInfoPanelViewTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForTransactions(selectedIds);
  }

  double _getTotalBalanceOfAccounts(final List<CategoryType> types) {
    double total = 0.0;
    getList().forEach((final Category category) {
      if (types.isEmpty || (category).type.value == types.first) {
        total += category.sum.value.toDouble();
      }
    });
    return total;
  }

  Widget _buildToggles() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: ToggleButtons(
          direction: Axis.horizontal,
          onPressed: (final int index) {
            setState(() {
              for (int i = 0; i < _selectedPivot.length; i++) {
                _selectedPivot[i] = i == index;
              }
              list = getList();
              clearSelection();
            });
          },
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 100.0,
          ),
          isSelected: _selectedPivot,
          children: _pivots,
        ));
  }

  List<CategoryType> _getSelectedCategoryType() {
    if (_selectedPivot[0]) {
      return [CategoryType.none];
    }
    if (_selectedPivot[1]) {
      return [CategoryType.expense, CategoryType.recurringExpense];
    }
    if (_selectedPivot[2]) {
      return [CategoryType.income];
    }
    if (_selectedPivot[3]) {
      return [CategoryType.saving];
    }
    if (_selectedPivot[4]) {
      return [CategoryType.investment];
    }

    return []; // all
  }
}
