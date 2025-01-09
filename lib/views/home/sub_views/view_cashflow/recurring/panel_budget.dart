import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/core/controller/preferences_controller.dart';
import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/core/widgets/columns/column_header_button.dart';
import 'package:money/core/widgets/dialog/dialog_button.dart';
import 'package:money/core/widgets/money_widget.dart';
import 'package:money/core/widgets/token_text.dart';
import 'package:money/data/models/budget.dart';
import 'package:money/data/models/money_objects/categories/category.dart';
import 'package:money/data/models/money_objects/transactions/transaction.dart';
import 'package:money/data/storage/data/data.dart';
import 'package:money/views/home/sub_views/adaptive_view/menu_entry.dart';
import 'package:money/views/home/sub_views/view_cashflow/recurring/recurring_expenses.dart';

class PanelBudget extends StatefulWidget {
  const PanelBudget({
    super.key,
    required this.dateRangeSearch,
    required this.minYear,
    required this.maxYear,
    required this.viewRecurringAs,
  });

  final DateRange dateRangeSearch;
  final int maxYear;
  final int minYear;
  final CashflowViewAs viewRecurringAs;

  @override
  State<PanelBudget> createState() => _PanelBudgetState();

  int get numberOfYears => max(1, maxYear - minYear);
}

class _PanelBudgetState extends State<PanelBudget> {
  List<RecurringExpenses> items = [];
  double sumForAllCategories = 0.00;
  double sumForAllCategoriesBudget = 0.00;

  late BudgetRecommendation _budget;
  bool _sortAscending = false;
  int _sortColumnIndex = 1;

  @override
  void initState() {
    super.initState();

    initializeItems();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildListOfExpenses(),
          ),
          _buildSuggestion(),
        ],
      ),
    );
  }

  void initializeItems() {
    bool whereClause(Transaction t) {
      return t.isCandidateForBudget &&
          isBetweenOrEqual(
            t.fieldDateTime.value!.year,
            widget.minYear,
            widget.maxYear,
          );
    }

    final List<Transaction> transactions = Data().transactions.getListFlattenSplits(whereClause: whereClause);

    final BudgetAnalyzer analyzer = BudgetAnalyzer(transactions);
    _budget = analyzer.calculateMonthlyBudget();

    items = RecurringExpenses.getRecurringItems(widget.minYear, widget.maxYear);
    sumForAllCategories = 0.00;
    sumForAllCategoriesBudget = 0.00;
    items.forEach((item) {
      sumForAllCategories += item.sum;
      sumForAllCategoriesBudget += item.category.fieldBudget.value.toDouble();
    });

    _sort();
  }

  Widget verticalLine(Color color) {
    return SizedBox(
      height: 38,
      child: VerticalDivider(
        color: color,
      ),
    );
  }

  Widget _buildListOfExpenses() {
    final Color dividersColor = Theme.of(context).dividerColor.withAlpha(100);

    return Column(
      children: [
        Container(
          color: getColorTheme(context).surfaceContainer,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              //
              // Column Header
              //
              Row(
                children: [
                  buildColumnHeaderButton(
                    context: context,
                    text: 'Category',
                    textAlign: TextAlign.start,
                    flex: 3,
                    sortIndicator: getSortIndicator(_sortColumnIndex, 0, _sortAscending),
                    onPressed: () => _onColumnSort(0),
                  ),
                  verticalLine(dividersColor),
                  buildColumnHeaderButton(
                    context: context,
                    text: 'Budgeted/M',
                    textAlign: TextAlign.end,
                    flex: 1,
                    sortIndicator: getSortIndicator(_sortColumnIndex, 4, _sortAscending),
                    onPressed: () => _onColumnSort(4),
                  ),
                  buildColumnHeaderButton(
                    context: context,
                    text: 'Actual/M',
                    textAlign: TextAlign.end,
                    flex: 1,
                    sortIndicator: getSortIndicator(_sortColumnIndex, 3, _sortAscending),
                    onPressed: () => _onColumnSort(3),
                  ),
                  verticalLine(dividersColor),
                  buildColumnHeaderButton(
                    context: context,
                    text: 'Budgeted/Y',
                    textAlign: TextAlign.end,
                    flex: 1,
                    sortIndicator: getSortIndicator(_sortColumnIndex, 4, _sortAscending),
                    onPressed: () => _onColumnSort(4),
                  ),
                  buildColumnHeaderButton(
                    context: context,
                    text: 'Actual/Y',
                    textAlign: TextAlign.end,
                    flex: 1,
                    sortIndicator: getSortIndicator(_sortColumnIndex, 2, _sortAscending),
                    onPressed: () => _onColumnSort(2),
                  ),
                  verticalLine(dividersColor),
                  buildColumnHeaderButton(
                    context: context,
                    text: 'Range',
                    textAlign: TextAlign.end,
                    flex: 1,
                  ),
                  buildColumnHeaderButton(
                    context: context,
                    text: 'All time',
                    textAlign: TextAlign.end,
                    flex: 1,
                    sortIndicator: getSortIndicator(_sortColumnIndex, 1, _sortAscending),
                    onPressed: () => _onColumnSort(1),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Column details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(
                height: 0,
                color: dividersColor,
              ),
              padding: EdgeInsets.all(0),
              itemCount: items.length,
              itemBuilder: (final BuildContext context, final int index) {
                // build the Card UI
                final RecurringExpenses item = items[index];
                return Row(
                  children: [
                    // Category Long Name
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          _categoryContextMenu(item.category),
                          Expanded(
                            child: item.category.getNameAsWidget(),
                          ),
                        ],
                      ),
                    ),
                    verticalLine(dividersColor),
                    // Budgeted and actual sum per month
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          // Budgeted per month
                          Expanded(
                            child: MoneyWidget.fromDouble(
                              item.category.fieldBudget.value.toDouble(),
                              asTitle: true,
                            ),
                          ),
                          Expanded(
                            child: MoneyWidget.fromDouble(
                              (item.sum / widget.numberOfYears) / 12,
                              asTitle: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // column line
                    verticalLine(dividersColor),

                    // Budgeted & actual per Year
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          // Budget per year
                          Expanded(
                            child: MoneyWidget.fromDouble(
                              item.category.fieldBudget.value.toDouble() * 12,
                              asTitle: true,
                            ),
                          ),

                          // Sum per year
                          Expanded(
                            child: MoneyWidget.fromDouble(
                              item.sum / widget.numberOfYears,
                              asTitle: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // column line
                    verticalLine(dividersColor),

                    // Date and range and total sum for all date
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.dates!.toStringYears(),
                              textAlign: TextAlign.right,
                              // style: TextStyle(fontSize: 10),
                            ),
                          ),
                          Expanded(
                            child: MoneyWidget.fromDouble(
                              item.sum,
                              asTitle: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        // Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 3,
              child: Text(''),
            ),
            verticalLine(dividersColor),
            Expanded(
              child: MoneyWidget.fromDouble(
                sumForAllCategoriesBudget,
                asTitle: true,
              ),
            ),
            Expanded(
              child: MoneyWidget.fromDouble(
                (sumForAllCategories / widget.numberOfYears) / 12,
                asTitle: true,
              ),
            ),
            verticalLine(dividersColor),
            Expanded(
              child: MoneyWidget.fromDouble(
                sumForAllCategoriesBudget * 12,
                asTitle: true,
              ),
            ),
            Expanded(
              child: MoneyWidget.fromDouble(
                sumForAllCategories / widget.numberOfYears,
                asTitle: true,
              ),
            ),
            verticalLine(dividersColor),
            Expanded(
              child: Text(''),
            ),
            Expanded(
              child: MoneyWidget.fromDouble(
                sumForAllCategories,
                asTitle: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestion() {
    List<Widget> widgets = [];

    final List<MapEntry<String, ExpenseBudget>> list = _budget.categoryBudgets.entries.toList();
    list.sort(
      (a, b) => a.value.monthlyAmount.compareTo(b.value.monthlyAmount),
    );

    for (final MapEntry<String, ExpenseBudget> categoryBudget in list) {
      widgets.add(
        Row(
          children: [
            _categoryContextMenu(Data().categories.getByName(categoryBudget.key)!),
            Expanded(
              child: TokenText(categoryBudget.key),
            ),
            Expanded(
              child: Text(categoryBudget.value.frequency.name),
            ),
            Expanded(
              child: MoneyWidget.fromDouble(categoryBudget.value.monthlyAmount.round().toDouble()),
            ),
          ],
        ),
      );
    }
    return ExpansionTile(
      title: const Text('Budget Suggestions'),
      children: [
        SizedBox(
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets,
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryContextMenu(final Category category) {
    return buildMenuButton(
      [
        MenuEntry.toCategory(category: category),
        MenuEntry.editCategory(
          category: category,
          onApplyChange: () {
            setState(() {
              // refresh the screen
            });
          },
        ),
      ],
      icon: Icons.more_vert,
    );
  }

  void _onColumnSort(int columnIndex) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
      }
      _sort();
    });
  }

  void _sort() {
    items.sort((RecurringExpenses a, RecurringExpenses b) {
      switch (_sortColumnIndex) {
        case 0:
          return sortByString(a.category.name, b.category.name, _sortAscending);
        case 1:
          return sortByValue(a.sum, b.sum, _sortAscending);
        case 2:
          return sortByValue(a.sum, b.sum, _sortAscending);
        case 3:
          return sortByValue(a.sum, b.sum, _sortAscending);
        case 4:
          return sortByValue(
            a.category.fieldBudget.value.toDouble(),
            b.category.fieldBudget.value.toDouble(),
            _sortAscending,
          );
        default:
          return sortByValue(a.sum, b.sum, _sortAscending);
      }
    });
  }
}
