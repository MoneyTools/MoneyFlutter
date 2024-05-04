import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/helpers/accumulator.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/money_objects/categories/category.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_cashflow/recurring/recurring_card.dart';
import 'package:money/views/view_cashflow/recurring/recurring_payment.dart';
import 'package:money/widgets/distribution_bar.dart';

enum ViewRecurringAs {
  incomes,
  expenses,
}

class PanelRecurrings extends StatefulWidget {
  final ViewRecurringAs viewRecurringAs;
  final int minYear;
  final int maxYear;

  const PanelRecurrings({super.key, required this.minYear, required this.maxYear, required this.viewRecurringAs});

  @override
  State<PanelRecurrings> createState() => _PanelRecurringsState();
}

class _PanelRecurringsState extends State<PanelRecurrings> {
  List<RecurringPayment> recurringPayments = [];

  @override
  Widget build(BuildContext context) {
    List<Widget> listOfCards = findAndCreateRecurringCards(context);

    return Container(
      color: getColorTheme(context).background,
      child: Center(
        child: SizedBox(
          width: 600,
          child: ListView.builder(
            padding: const EdgeInsets.all(21),
            itemCount: listOfCards.length,
            itemBuilder: (context, index) => listOfCards[index],
          ),
        ),
      ),
    );
  }

  List<Widget> findAndCreateRecurringCards(BuildContext context) {
    // get all transactions
    final transactions = Data().transactions.transactionInYearRange(
          minYear: widget.minYear,
          maxYear: widget.maxYear,
          onlyIncome: widget.viewRecurringAs == ViewRecurringAs.incomes,
        );

    // get all transaction Income | Expenses
    recurringPayments = findMonthlyRecurringPayments(
      transactions.toList(),
      widget.viewRecurringAs == ViewRecurringAs.incomes,
    );

    // Sort descending
    if (widget.viewRecurringAs == ViewRecurringAs.incomes) {
      recurringPayments.sort((a, b) => b.total.compareTo(a.total));
    } else {
      recurringPayments.sort((a, b) => a.total.compareTo(b.total));
    }

    List<Widget> widgets = [];

    for (final RecurringPayment payment in recurringPayments) {
      widgets.add(_buildRecurringCard(
        context,
        payment,
        widget.viewRecurringAs == ViewRecurringAs.incomes,
      ));
    }
    return widgets;
  }

  Color getColorFromText(String? text) {
    if (text == null) {
      return Colors.transparent;
    }
    return getColorFromString(text);
  }

  Widget _buildRecurringCard(BuildContext context, RecurringPayment payment, bool asIncome) {
    List<Pair<int, double>> list = payment.getListOfCategoryIdAndSum();
    // Sort descending
    if (asIncome) {
      list.sort((a, b) => b.second.compareTo(a.second));
    } else {
      list.sort((a, b) => a.second.compareTo(b.second));
    }

    List<Distribution> listForDistributionBar = [];

    // keep at most [n] number of items
    int topCategoryToShow = min(4, list.length);
    for (final categoryIdAndSum in list.take(topCategoryToShow)) {
      final Category? category = Data().categories.get(categoryIdAndSum.first);
      if (category == null) {
        listForDistributionBar.add(Distribution(
          title: '< no category >',
          color: Colors.transparent,
          amount: categoryIdAndSum.second,
        ));
      } else {
        listForDistributionBar.add(Distribution(
          title: category.name.value,
          color: category.getColorOrAncestorsColor(),
          amount: categoryIdAndSum.second,
        ));
      }
    }

    return RecurringCard(payment: payment, listForDistributionBar: listForDistributionBar);
  }

  Widget header(final BuildContext context, final String title) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Text(
        title,
        style: getTextTheme(context).titleLarge!,
      ),
    );
  }

  List<RecurringPayment> findMonthlyRecurringPayments(List<Transaction> transactions, bool forIncome) {
    AccumulatorList<int, double> payeeIdToAmounts = AccumulatorList<int, double>();
    AccumulatorList<int, int> payeeIdToMonths = AccumulatorList<int, int>();
    Map<int, AccumulatorSum<int, double>> payeeIdCategoryIdsAndSums = {};

    // Step 1: Group transactions by payeeId and record transaction months
    for (var transaction in transactions) {
      if (forIncome && transaction.amount.value.amount > 0 ||
          forIncome == false && transaction.amount.value.amount <= 0) {
        int payeeId = transaction.payee.value;
        payeeIdToAmounts.cumulate(payeeId, transaction.amount.value.amount);
        payeeIdToMonths.cumulate(payeeId, transaction.dateTime.value!.month);

        if (!payeeIdCategoryIdsAndSums.containsKey(payeeId)) {
          payeeIdCategoryIdsAndSums[payeeId] = AccumulatorSum<int, double>();
        }
        payeeIdCategoryIdsAndSums[payeeId]!.cumulate(transaction.categoryId.value, transaction.amount.value.amount);
      }
    }

    // Step 2: Calculate average amount and frequency for each payeeId
    List<RecurringPayment> monthlyRecurringPayments = [];
    final numberOfYears = (widget.maxYear - widget.minYear) + 1;

    payeeIdToAmounts.getKeys().forEach(
      (payeeId) {
        List<double> amounts = payeeIdToAmounts.getValues(payeeId);
        List<int> months = payeeIdToMonths.getValues(payeeId);

        double totalAmount = amounts.reduce((a, b) => a + b);
        int frequency = amounts.length;

        // Check if the frequency indicates monthly recurrence
        if (isMonthlyRecurrence(months)) {
          monthlyRecurringPayments.add(
            RecurringPayment(
              payeeId,
              numberOfYears,
              totalAmount,
              frequency,
              convertMapToListOfPair<int, double>(payeeIdCategoryIdsAndSums[payeeId]!.values),
            ),
          );
        }
      },
    );

    return monthlyRecurringPayments;
  }

  bool isMonthlyRecurrence(List<int> months) {
    // Check if the months between transactions suggest a monthly recurrence
    Set<int> uniqueMonths = months.toSet();

    // we can conclude that if paid more than 5 months its a recurring monthly event
    return uniqueMonths.length >= Settings().cashflowRecurringOccurrences;
  }
}
