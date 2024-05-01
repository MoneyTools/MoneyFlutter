import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/money_model.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/widgets/box.dart';
import 'package:money/widgets/money_widget.dart';

class PanelRecurrings extends StatefulWidget {
  final int minYear;
  final int maxYear;

  const PanelRecurrings({super.key, required this.minYear, required this.maxYear});

  @override
  State<PanelRecurrings> createState() => _PanelRecurringsState();
}

class _PanelRecurringsState extends State<PanelRecurrings> {
  List<RecurringPayment> recurringPayments = [];

  @override
  Widget build(BuildContext context) {
    final transactions = Data().transactions.transactionInYearRange(widget.minYear, widget.maxYear);

    recurringPayments = findMonthlyRecurringPayments(transactions.toList());

    List<Widget> widgetsIncomes = [];
    List<Widget> widgetsExpenses = [];

    for (final payment in recurringPayments) {
      final card = Box(
        margin: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              Data().payees.getNameFromId(payment.payeeId),
              style: getTextTheme(context).titleMedium,
            ),
            Row(
              children: [
                SelectableText('${payment.frequency} occurrence with an average '),
                MoneyWidget(amountModel: MoneyModel(amount: payment.averageAmount)),
              ],
            ),
          ],
        ),
      );
      if (payment.averageAmount <= 0) {
        widgetsExpenses.add(card);
      } else {
        widgetsIncomes.add(card);
      }
    }
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header(context, 'Incomes'),
          Wrap(children: widgetsIncomes),
          header(context, 'Expenses'),
          Wrap(children: widgetsExpenses),
        ],
      ),
    );
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
}

class RecurringPayment {
  int payeeId;
  double averageAmount;
  int frequency;

  RecurringPayment(this.payeeId, this.averageAmount, this.frequency);
}

List<RecurringPayment> findMonthlyRecurringPayments(List<Transaction> transactions) {
  Map<int, List<double>> payeeIdToAmounts = {};
  Map<int, List<int>> payeeIdToMonths = {};

  // Step 1: Group transactions by payeeId and record transaction months
  for (var transaction in transactions) {
    if (!payeeIdToAmounts.containsKey(transaction.payee.value)) {
      payeeIdToAmounts[transaction.payee.value] = [];
      payeeIdToMonths[transaction.payee.value] = [];
    }
    payeeIdToAmounts[transaction.payee.value]!.add(transaction.amount.value.amount);
    payeeIdToMonths[transaction.payee.value]!.add(transaction.dateTime.value!.month);
  }

  // Step 2: Calculate average amount and frequency for each payeeId
  List<RecurringPayment> monthlyRecurringPayments = [];
  payeeIdToAmounts.forEach((payeeId, amounts) {
    List<int> months = payeeIdToMonths[payeeId]!;
    double totalAmount = amounts.reduce((a, b) => a + b);
    double averageAmount = totalAmount / amounts.length;
    int frequency = amounts.length;

    // Check if the frequency indicates monthly recurrence
    if (frequency > 2 && isMonthlyRecurrence(months)) {
      monthlyRecurringPayments.add(RecurringPayment(payeeId, averageAmount, frequency));
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
