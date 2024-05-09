import 'package:flutter/material.dart';
import 'package:money/helpers/accumulator.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_cashflow/recurring/recurring_card.dart';
import 'package:money/views/view_cashflow/recurring/recurring_payment.dart';

class PanelRecurrings extends StatefulWidget {
  final CashflowViewAs viewRecurringAs;
  final DateRange dateRangeSearch;
  final int minYear;
  final int maxYear;

  const PanelRecurrings({
    super.key,
    required this.dateRangeSearch,
    required this.minYear,
    required this.maxYear,
    required this.viewRecurringAs,
  });

  @override
  State<PanelRecurrings> createState() => _PanelRecurringsState();
}

class _PanelRecurringsState extends State<PanelRecurrings> {
  List<RecurringPayment> recurringPayments = [];
  late bool forIncomeTransaction;

  @override
  void initState() {
    super.initState();
    forIncomeTransaction = widget.viewRecurringAs == CashflowViewAs.recurringIncomes;
    initRecurringTransactions(forIncome: forIncomeTransaction);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: getColorTheme(context).background,
      child: ListView.builder(
          padding: const EdgeInsets.all(21),
          itemCount: recurringPayments.length,
          itemBuilder: (context, index) {
            // build the Card UI
            final payment = recurringPayments[index];
            return RecurringCard(
              index: index + 1,
              dateRangeSearch: widget.dateRangeSearch,
              dateRangeSelected: DateRange.fromStarEndYears(widget.minYear, widget.maxYear),
              payment: payment,
              forIncomeTransaction: forIncomeTransaction,
            );
          }),
    );
  }

  void initRecurringTransactions({required final bool forIncome}) {
    // get all transactions
    final transactions = Data().transactions.transactionInYearRange(
          minYear: widget.minYear,
          maxYear: widget.maxYear,
          incomesOrExpenses: forIncome,
        );

    final flatTransactions = Data().transactions.flatTransactions(transactions);

    // get all transaction Income | Expenses
    // recurringPayments =
    findMonthlyRecurringPayments(flatTransactions, forIncome);

    // Sort descending - biggest amount first
    if (widget.viewRecurringAs == CashflowViewAs.recurringIncomes) {
      recurringPayments.sort((a, b) => b.total.compareTo(a.total));
    }
    if (widget.viewRecurringAs == CashflowViewAs.recurringExpenses) {
      recurringPayments.sort((a, b) => a.total.compareTo(b.total));
    }
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

  void findMonthlyRecurringPayments(List<Transaction> transactions, bool isIncomeTransaction) {
    // reset the content
    recurringPayments.clear();

    AccumulatorList<int, Transaction> groupTransactionsByPayeeId = AccumulatorList<int, Transaction>();
    AccumulatorList<int, int> groupMonthsListByPayeeId = AccumulatorList<int, int>();

    // Step 1: Group transactions by payeeId and record transaction months
    for (final transaction in transactions.where((final t) =>
        (isIncomeTransaction && t.amount.value.amount > 0) ||
        (isIncomeTransaction == false && t.amount.value.amount <= 0))) {
      int payeeId = transaction.payee.value;

      groupTransactionsByPayeeId.cumulate(payeeId, transaction);
      groupMonthsListByPayeeId.cumulate(payeeId, transaction.dateTime.value!.month);
    }

    // Step 2: Calculate average amount and frequency for each payeeId
    for (final payeeId in groupMonthsListByPayeeId.getKeys()) {
      List<int> months = groupMonthsListByPayeeId.getList(payeeId);

      // Check if the frequency indicates monthly recurrence
      if (isMonthlyRecurrence(months)) {
        // keep this payment
        recurringPayments.add(
          RecurringPayment(
            payeeId: payeeId,
            forIncomeTransaction: isIncomeTransaction,
            transactions: groupTransactionsByPayeeId.getList(payeeId),
          ),
        );
      }
    }
  }

  bool isMonthlyRecurrence(List<int> months) {
    if (widget.minYear == widget.maxYear) {
      return true;
    }
    // we can conclude that if paid more than 'n' months its a recurring monthly event
    return months.length == Settings().cashflowRecurringOccurrences;
  }
}
