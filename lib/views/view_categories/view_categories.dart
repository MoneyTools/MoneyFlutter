import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/categories/category.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/widgets/center_message.dart';
import 'package:money/widgets/three_part_label.dart';
import 'package:money/widgets/chart.dart';
import 'package:money/views/view.dart';
import 'package:money/widgets/list_view/transactions/list_view_transactions.dart';

part 'view_categories_details_panels.dart';

class ViewCategories extends ViewWidget<Category> {
  const ViewCategories({super.key});

  @override
  State<ViewWidget<Category>> createState() => ViewCategoriesState();
}

class ViewCategoriesState extends ViewWidgetState<Category> {
  final List<Widget> pivots = <Widget>[];
  final List<bool> _selectedPivot = <bool>[false, false, false, false, false, true];

  @override
  void initState() {
    super.initState();

    pivots.add(ThreePartLabel(
        text1: 'None',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(<CategoryType>[CategoryType.none]))));
    pivots.add(ThreePartLabel(
        text1: 'Expense',
        small: true,
        isVertical: true,
        text2:
            Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(<CategoryType>[CategoryType.expense]))));
    pivots.add(ThreePartLabel(
        text1: 'Income',
        small: true,
        isVertical: true,
        text2:
            Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(<CategoryType>[CategoryType.income]))));
    pivots.add(ThreePartLabel(
        text1: 'Saving',
        small: true,
        isVertical: true,
        text2:
            Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(<CategoryType>[CategoryType.saving]))));
    pivots.add(ThreePartLabel(
        text1: 'Investment',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(
            getTotalBalanceOfAccounts(<CategoryType>[CategoryType.investment]))));
    pivots.add(ThreePartLabel(
        text1: 'All',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(<CategoryType>[]))));
  }

  double getTotalBalanceOfAccounts(final List<CategoryType> types) {
    double total = 0.0;
    getList().forEach((final Category category) {
      if (types.isEmpty || (category).type.value == types.first) {
        total += category.runningBalance.value;
      }
    });
    return total;
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
  Widget buildHeader([final Widget? child]) {
    return super.buildHeader(renderToggles());
  }

  @override
  List<Category> getList([bool includeDeleted = false]) {
    final CategoryType? filterType = getSelectedCategoryType();
    return Data()
        .categories
        .iterableList(includeDeleted)
        .where((final Category x) => (filterType == null || x.type.value == filterType) && isMatchingFilterText(x))
        .toList();
  }

  CategoryType? getSelectedCategoryType() {
    if (_selectedPivot[0]) {
      return CategoryType.none;
    }

    if (_selectedPivot[1]) {
      return CategoryType.expense;
    }
    if (_selectedPivot[2]) {
      return CategoryType.income;
    }
    if (_selectedPivot[3]) {
      return CategoryType.saving;
    }
    if (_selectedPivot[4]) {
      return CategoryType.investment;
    }

    return null; // all
  }

  Widget renderToggles() {
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
              selectedItems.value.clear();
            });
          },
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 100.0,
          ),
          isSelected: _selectedPivot,
          children: pivots,
        ));
  }

  @override
  Widget getPanelForChart(final List<int> indices) {
    return _getSubViewContentForChart(indices);
  }

  @override
  Widget getPanelForTransactions({
    required final List<int> selectedItems,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForTransactions(selectedItems);
  }

  @override
  void onDeleteConfirmedByUser(final MoneyObject instance) {
    setState(() {
      Data().categories.deleteItem(instance);
    });
  }
}
