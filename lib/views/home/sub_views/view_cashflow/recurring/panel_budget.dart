import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/core/controller/preferences_controller.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/core/widgets/money_widget.dart';
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
          // Column explanation
          Padding(
            padding: const EdgeInsets.all(13.0),
            child: Row(
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
              ],
            ),
          ),

          //
          // Column values
          //
          Padding(
            padding: const EdgeInsets.all(13.0),
            child: Row(
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
              ],
            ),
          ),

          // Column details
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                // build the Card UI
                final RecurringExpenses item = items[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 2,
                          child: item.category.getNameAsWidget(),
                        ),
                        Expanded(
                          child: MoneyWidget.fromDouble(
                            item.sum,
                            asTitle: true,
                          ),
                        ),
                        Expanded(
                          child: MoneyWidget.fromDouble(
                            item.sum / widget.numberOfYears,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void initializeItems() {
    items = RecurringExpenses.getRecurringItems(widget.minYear, widget.maxYear);
    sumForAllCategories = 0.00;
    items.forEach((item) => sumForAllCategories += item.sum);
  }
}
