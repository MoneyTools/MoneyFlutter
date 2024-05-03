import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/helpers/accumulator.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/money_model.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_cashflow/recurring/recurring_payment.dart';
import 'package:money/widgets/box.dart';
import 'package:money/widgets/distribution_bar.dart';
import 'package:money/widgets/money_widget.dart';
import 'package:money/widgets/top_bars.dart';

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
    final transactions = Data().transactions.transactionInYearRange(widget.minYear, widget.maxYear);

    recurringPayments = findMonthlyRecurringPayments(
      transactions.toList(),
      widget.viewRecurringAs == ViewRecurringAs.incomes,
    );

    // Sort descending
    recurringPayments.sort((a, b) {
      return b.averageAmount.compareTo(a.averageAmount);
    });

    List<Widget> widgets = [];

    for (final RecurringPayment payment in recurringPayments) {
      widgets.add(_buildRecurringCard(
        context,
        payment,
        widget.viewRecurringAs == ViewRecurringAs.incomes,
      ));
    }

    return Container(
      color: getColorTheme(context).surfaceVariant,
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 20,
            spacing: 20,
            children: widgets,
          ),
        ),
      ),
    );
  }

  Color getColorFromText(String? text) {
    if (text == null) {
      return Colors.transparent;
    }
    return getColorFromString(text);
  }

  Widget _buildRecurringCard(BuildContext context, RecurringPayment payment, bool asIncome) {
    final List<KeyValue> lkv = getCategoriesOfPayee(payment);
    List<KeyValue> listAsPercentage = convertToPercentages(lkv);
    listAsPercentage.sort((a, b) => b.value.compareTo(a.value));

    // Extract top 3 values and calculate total value of others
    int topCategoryToShow = min(3, listAsPercentage.length);
    listAsPercentage = listAsPercentage.take(topCategoryToShow).toList();

    List<Color> colors = [];
    List<double> distributionInPercentages = [];
    double percentageRemaining = 1;

    for (final kvp in listAsPercentage) {
      if (kvp.key == -1) {
        colors.add(Colors.transparent);
      } else {
        colors.add(Data().categories.get(kvp.key)!.getColorOrAncestorsColor());
      }
      double percentageForThisCategory = kvp.value / 100;
      percentageRemaining -= percentageForThisCategory;
      distributionInPercentages.add(percentageForThisCategory);
    }

    if (percentageRemaining > 0.5) {
      colors.add(Colors.grey);
      distributionInPercentages.add(percentageRemaining);
    }

    return Box(
      color: getColorTheme(context).background,
      width: 400,
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  Data().payees.getNameFromId(payment.payeeId),
                  style: getTextTheme(context).titleMedium,
                ),
                Row(
                  children: [
                    SelectableText('${payment.frequency} occurrence with an average '),
                    MoneyWidget(amountModel: MoneyModel(amount: payment.averageAmount * (asIncome ? 1 : -1))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DistributionBar(
                  colors: colors,
                  percentages: distributionInPercentages, // Percentages for segments
                ),
                BarChartWidget(listCategoryNameToAmount: getCategoriesOfPayee(payment), asIncome: asIncome),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<KeyValue> getCategoriesOfPayee(RecurringPayment payment) {
    List<KeyValue> kvs = [];
    for (int i = 0; i < payment.categoryIds.length; i++) {
      kvs.add(KeyValue(
        key: payment.categoryIds[i],
        value: payment.categorySums[i],
      ));
    }
    return kvs;
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
    AccumulatorList<int, int> payeeIdCategoryIds = AccumulatorList<int, int>();

    // Step 1: Group transactions by payeeId and record transaction months
    for (var transaction in transactions) {
      if (forIncome && transaction.amount.value.amount > 0 ||
          forIncome == false && transaction.amount.value.amount <= 0) {
        payeeIdToAmounts.cumulate(transaction.payee.value, transaction.amount.value.amount.abs());
        payeeIdToMonths.cumulate(transaction.payee.value, transaction.dateTime.value!.month);
        payeeIdCategoryIds.cumulate(transaction.payee.value, transaction.categoryId.value);
      }
    }

    // Step 2: Calculate average amount and frequency for each payeeId
    List<RecurringPayment> monthlyRecurringPayments = [];
    payeeIdToAmounts.getKeys().forEach((payeeId) {
      List<double> amounts = payeeIdToAmounts.getValues(payeeId);
      List<int> months = payeeIdToMonths.getValues(payeeId);
      double totalAmount = amounts.reduce((a, b) => a + b);
      double averageAmount = totalAmount / amounts.length;
      int frequency = amounts.length;

      // Check if the frequency indicates monthly recurrence
      if (frequency > 2 && isMonthlyRecurrence(months)) {
        monthlyRecurringPayments.add(
          RecurringPayment(
            payeeId,
            averageAmount,
            frequency,
            payeeIdCategoryIds.getValues(payeeId),
            payeeIdToAmounts.getValues(payeeId),
          ),
        );
      }
    });

    return monthlyRecurringPayments;
  }

  bool isMonthlyRecurrence(List<int> months) {
    // Check if the months between transactions suggest a monthly recurrence
    Set<int> uniqueMonths = months.toSet();

    // we can conclude that if paid more than 5 months its a recurring monthly event
    return uniqueMonths.length >= 6;
  }
}
