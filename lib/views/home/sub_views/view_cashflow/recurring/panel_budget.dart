import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/core/controller/preferences_controller.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/core/widgets/money_widget.dart';
import 'package:money/data/models/money_objects/categories/category.dart';
import 'package:money/data/models/money_objects/transactions/transactions.dart';
import 'package:money/data/storage/data/data.dart';

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

class RecurringExpenses {
  RecurringExpenses(this.category, this.sum);

  final Category category;
  final double sum;
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
    sumForAllCategories = 0.00;
    final recurringCategories =
        Data().categories.iterableList().where((c) => c.fieldType.value == CategoryType.recurringExpense);

    for (final category in recurringCategories) {
      // get all transactions meeting the request of date and type
      bool whereClause(Transaction t) {
        return t.category == category && isBetweenOrEqual(t.fieldDateTime.value!.year, widget.minYear, widget.maxYear);
      }

      final List<Transaction> flatTransactions = Data().transactions.getListFlattenSplits(whereClause: whereClause);
      final sumOfTransactionsForCategory =
          flatTransactions.fold<double>(0, (p, e) => p + e.fieldAmount.value.toDouble());
      final item = RecurringExpenses(category, sumOfTransactionsForCategory);
      items.add(item);
      sumForAllCategories += sumOfTransactionsForCategory;
    }
    items.sort(
      (a, b) => a.sum.compareTo(b.sum),
    );
  }
}
