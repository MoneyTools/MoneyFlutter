import 'package:flutter/material.dart';

import '../helpers.dart';
import '../models/categories.dart';
import '../widgets/columns.dart';
import '../widgets/header.dart';
import '../widgets/caption_and_counter.dart';
import '../widgets/widget_view.dart';

class ViewCategories extends ViewWidget {
  const ViewCategories({super.key});

  @override
  State<ViewWidget> createState() => ViewCategoriesState();
}

class ViewCategoriesState extends ViewWidgetState {
  final List<Widget> pivots = [];
  final List<bool> _selectedPivot = <bool>[false, false, false, false, false, true];

  @override
  void initState() {
    super.initState();

    pivots.add(CaptionAndCounter(caption: 'None', small: true, vertical: true, value: getTotalBalanceOfAccounts([CategoryType.none])));
    pivots.add(CaptionAndCounter(caption: 'Expense', small: true, vertical: true, value: getTotalBalanceOfAccounts([CategoryType.expense])));
    pivots.add(CaptionAndCounter(caption: 'Income', small: true, vertical: true, value: getTotalBalanceOfAccounts([CategoryType.income])));
    pivots.add(CaptionAndCounter(caption: 'Saving', small: true, vertical: true, value: getTotalBalanceOfAccounts([CategoryType.saving])));
    pivots.add(CaptionAndCounter(caption: 'Investment', small: true, vertical: true, value: getTotalBalanceOfAccounts([CategoryType.investment])));
    pivots.add(CaptionAndCounter(caption: 'All', small: true, vertical: true, value: getTotalBalanceOfAccounts([])));
  }

  double getTotalBalanceOfAccounts(List<CategoryType> types) {
    var total = 0.0;
    getList().forEach((x) {
      if (types.isEmpty || x.type == types.first) {
        total += x.balance;
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
    return Column(children: [
      Header(getClassNamePlural(), numValueOrDefault(list.length), getDescription()),
      renderToggles(),
    ]);
  }

  @override
  ColumnDefinitions getColumnDefinitionsForTable() {
    return ColumnDefinitions([
      ColumnDefinition(
        'Name',
        ColumnType.text,
        TextAlign.left,
        (index) {
          return list[index].name;
        },
        (a, b, sortAscending) {
          return sortByString(a.name, b.name, sortAscending);
        },
      ),
      ColumnDefinition(
        'Type',
        ColumnType.text,
        TextAlign.center,
        (index) {
          return list[index].getTypeAsText();
        },
        (a, b, sortAscending) {
          return sortByString(a.getTypeAsText(), b.getTypeAsText(), sortAscending);
        },
      ),
      ColumnDefinition(
        'Count',
        ColumnType.numeric,
        TextAlign.right,
        (index) {
          return list[index].count;
        },
        (a, b, sortAscending) {
          return sortByValue(a.count, b.count, sortAscending);
        },
      ),
      ColumnDefinition(
        'Balance',
        ColumnType.amount,
        TextAlign.right,
        (index) {
          return list[index].balance;
        },
        (a, b, sortAscending) {
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
  getList() {
    final filterType = getSelectedCategoryType();
    return Categories.moneyObjects.getAsList().where((x) => filterType == null || (x as Category).type == filterType).toList();
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

  renderToggles() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: ToggleButtons(
          direction: Axis.horizontal,
          onPressed: (int index) {
            setState(() {
              for (int i = 0; i < _selectedPivot.length; i++) {
                _selectedPivot[i] = i == index;
              }
              list = getList();
              selectedItems.clear();
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
}
