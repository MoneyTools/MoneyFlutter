import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/core/controller/preferences_controller.dart';
import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/core/widgets/dialog/dialog_button.dart';
import 'package:money/core/widgets/money_widget.dart';
import 'package:money/views/home/sub_views/adaptive_view/switch_views.dart';
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

  @override
  void initState() {
    super.initState();

    initializeItems();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            color: getColorTheme(context).surfaceContainer,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                //
                // Column title
                //
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text('Category'),
                    ),
                    Expanded(
                      child: Text(
                        'Total',
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Yearly',
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Monthly',
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Budgeted',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),

                //
                // Column values
                //
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(''),
                    ),
                    Expanded(
                      child: MoneyWidget.fromDouble(
                        sumForAllCategories,
                        asTitle: true,
                      ),
                    ),
                    Expanded(
                      child: MoneyWidget.fromDouble(
                        sumForAllCategories / widget.numberOfYears,
                        asTitle: true,
                      ),
                    ),
                    Expanded(
                      child: MoneyWidget.fromDouble(
                        (sumForAllCategories / widget.numberOfYears) / 12,
                        asTitle: true,
                      ),
                    ),
                    Expanded(
                      child: MoneyWidget.fromDouble(
                        sumForAllCategoriesBudget,
                        asTitle: true,
                      ),
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
                separatorBuilder: (context, index) => const Divider(height: 0),
                padding: EdgeInsets.all(0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  // build the Card UI
                  final RecurringExpenses item = items[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Category Long Name
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              child: item.category.getNameAsWidget(),
                            ),
                            buildMenuButton(
                              [
                                MenuEntry.toCategory(category: item.category),
                                MenuEntry.editCategory(
                                  category: item.category,
                                  onApplyChange: () {
                                    setState(() {
                                      // refresh the screen
                                    });
                                  },
                                ),
                              ],
                              icon: Icons.more_vert,
                            ),
                          ],
                        ),
                      ),

                      // Sum for all date
                      Expanded(
                        child: MoneyWidget.fromDouble(
                          item.sum,
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

                      // Sum per month
                      Expanded(
                        child: MoneyWidget.fromDouble(
                          (item.sum / widget.numberOfYears) / 12,
                          asTitle: true,
                        ),
                      ),

                      // Budgeted per month
                      Expanded(
                        child: MoneyWidget.fromDouble(
                          item.category.fieldBudget.value.toDouble(),
                          asTitle: true,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void initializeItems() {
    items = RecurringExpenses.getRecurringItems(widget.minYear, widget.maxYear);
    sumForAllCategories = 0.00;
    sumForAllCategoriesBudget = 0.00;
    items.forEach((item) {
      sumForAllCategories += item.sum;
      sumForAllCategoriesBudget += item.category.fieldBudget.value.toDouble();
    });
  }
}
