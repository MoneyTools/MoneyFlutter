import 'package:flutter/material.dart';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/categories.dart';
import 'package:money/models/transactions.dart';
import 'package:money/views/view_transactions.dart';
import 'package:money/widgets/fields/field.dart';
import 'package:money/widgets/fields/fields.dart';
import 'package:money/widgets/header.dart';
import 'package:money/widgets/caption_and_counter.dart';
import 'package:money/widgets/chart.dart';
import 'package:money/views/view.dart';

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

    pivots.add(CaptionAndCounter(
        caption: 'None',
        small: true,
        vertical: true,
        value: getTotalBalanceOfAccounts(<CategoryType>[CategoryType.none])));
    pivots.add(CaptionAndCounter(
        caption: 'Expense',
        small: true,
        vertical: true,
        value: getTotalBalanceOfAccounts(<CategoryType>[CategoryType.expense])));
    pivots.add(CaptionAndCounter(
        caption: 'Income',
        small: true,
        vertical: true,
        value: getTotalBalanceOfAccounts(<CategoryType>[CategoryType.income])));
    pivots.add(CaptionAndCounter(
        caption: 'Saving',
        small: true,
        vertical: true,
        value: getTotalBalanceOfAccounts(<CategoryType>[CategoryType.saving])));
    pivots.add(CaptionAndCounter(
        caption: 'Investment',
        small: true,
        vertical: true,
        value: getTotalBalanceOfAccounts(<CategoryType>[CategoryType.investment])));
    pivots.add(CaptionAndCounter(
        caption: 'All', small: true, vertical: true, value: getTotalBalanceOfAccounts(<CategoryType>[])));
  }

  double getTotalBalanceOfAccounts(final List<CategoryType> types) {
    double total = 0.0;
    getList().forEach((final Category x) {
      if (types.isEmpty || (x).type == types.first) {
        total += (x).balance;
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
  Widget getTitle() {
    return Column(children: <Widget>[
      Header(getClassNamePlural(), numValueOrDefault(list.length), getDescription()),
      renderToggles(),
    ]);
  }

  @override
  FieldDefinitions<Category> getFieldDefinitionsForTable() {
    return FieldDefinitions<Category>(list: <FieldDefinition<Category>>[
      FieldDefinition<Category>(
        name: 'Name',
        type: FieldType.text,
        align: TextAlign.left,
        value: (final int index) {
          return list[index].name;
        },
        sort: (final Category a, final Category b, final bool sortAscending) {
          return sortByString(a.name, b.name, sortAscending);
        },
      ),
      FieldDefinition<Category>(
        name: 'Type',
        type: FieldType.text,
        align: TextAlign.center,
        value: (final int index) {
          return (list[index]).getTypeAsText();
        },
        sort: (final Category a, final Category b, final bool sortAscending) {
          return sortByString(
            a.getTypeAsText(),
            b.getTypeAsText(),
            sortAscending,
          );
        },
      ),
      FieldDefinition<Category>(
        name: 'Count',
        type: FieldType.numeric,
        align: TextAlign.right,
        value: (final int index) {
          return list[index].count;
        },
        sort: (final Category a, final Category b, final bool sortAscending) {
          return sortByValue(a.count, b.count, sortAscending);
        },
      ),
      FieldDefinition<Category>(
        name: 'Balance',
        type: FieldType.amount,
        align: TextAlign.right,
        value: (final int index) {
          return list[index].balance;
        },
        sort: (final Category a, final Category b, final bool sortAscending) {
          return sortByValue(a.balance, b.balance, sortAscending);
        },
      ),
    ]);
  }

  @override
  getDefaultSortColumn() {
    return 0; // Sort by name
  }

  @override
  List<Category> getList() {
    final CategoryType? filterType = getSelectedCategoryType();
    return Categories.moneyObjects
        .getAsList()
        .where((final Category x) => filterType == null || x.type == filterType)
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
  Widget getSubViewContentForChart(final List<int> indices) {
    final Map<String, num> map = <String, num>{};

    for (final Category item in getList()) {
      if (item.name != 'Split' && item.name != 'Xfer to Deleted Account') {
        final Category topCategory = Categories.getTopAncestor(item);
        if (map[topCategory.name] == null) {
          map[topCategory.name] = 0;
        }
        map[topCategory.name] = map[topCategory.name]! + item.balance;
      }
    }
    final List<PairXY> list = <PairXY>[];
    map.forEach((final String key, final num value) {
      list.add(PairXY(key, value));
    });

    list.sort((final PairXY a, final PairXY b) {
      return (b.yValue.abs() - a.yValue.abs()).toInt();
    });

    return Chart(
      key: Key(indices.toString()),
      list: list.take(8).toList(),
      variableNameHorizontal: 'Category',
      variableNameVertical: 'Balance',
    );
  }

  @override
  getSubViewContentForTransactions(final List<int> indices) {
    final Category? category = getFirstElement<Category>(indices, list);
    if (category != null && category.id > -1) {
      return ViewTransactions(
        key: Key(category.id.toString()),
        filter: (final Transaction transaction) => transaction.categoryId == category.id,
        preference: preferenceJustTableDatePayeeCategoryAmountBalance,
        startingBalance: 0,
      );
    }
    return const Text('No transactions');
  }
}
