import 'package:flutter/material.dart';
import 'package:money/helpers/accumulator.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/money_model.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/widgets/box.dart';
import 'package:money/widgets/money_widget.dart';
import 'package:money/widgets/top_bars.dart';

class PayeeCumulate {
  int payeeId = -1;
  int numberOfInstances = 0;
  List<Map<int, double>> amountByCategories = [];
}

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
  List<RecurringPayment> recurringPaymentsIncome = [];
  List<RecurringPayment> recurringPaymentsExpenses = [];

  @override
  Widget build(BuildContext context) {
    final transactions = Data().transactions.transactionInYearRange(widget.minYear, widget.maxYear);

    recurringPaymentsIncome =
        findMonthlyRecurringPayments(transactions.toList(), widget.viewRecurringAs == ViewRecurringAs.incomes);
    List<Widget> widgetsIncomes = [];
    for (final RecurringPayment payment in recurringPaymentsIncome) {
      widgetsIncomes.add(createCardOutOfPayments(context, payment, widget.viewRecurringAs == ViewRecurringAs.incomes));
    }

    return SingleChildScrollView(
      child: Wrap(children: widgetsIncomes),
    );
  }

  Widget createCardOutOfPayments(BuildContext context, RecurringPayment payment, bool asIncome) {
    return Box(
      margin: 4,
      width: 400,
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            Data().payees.getNameFromId(payment.payeeId),
            style: getTextTheme(context).titleMedium,
          ),
          const Spacer(),
          Row(
            children: [
              SelectableText('${payment.frequency} occurrence with an average '),
              MoneyWidget(amountModel: MoneyModel(amount: payment.averageAmount * (asIncome ? 1 : -1))),
            ],
          ),
          const Spacer(),
          BarChartWidget(listAsAmount: getCategoriesOfPayee(payment), asIncome: asIncome),
        ],
      ),
    );
  }

  List<KeyValue> getCategoriesOfPayee(RecurringPayment payment) {
    List<KeyValue> kvs = [];
    for (int i = 0; i < payment.categoryIds.length; i++) {
      kvs.add(KeyValue(
        key: Data().categories.getNameFromId(payment.categoryIds[i]),
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
}

class RecurringPayment {
  int payeeId;
  double averageAmount;
  int frequency;
  List<int> categoryIds = [];
  List<double> categorySums = [];

  RecurringPayment(this.payeeId, this.averageAmount, this.frequency, this.categoryIds, this.categorySums);
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
