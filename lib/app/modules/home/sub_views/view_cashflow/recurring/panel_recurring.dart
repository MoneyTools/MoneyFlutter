import 'package:flutter/material.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/core/helpers/accumulator.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/ranges.dart';

import 'package:money/app/data/models/money_objects/transactions/transactions.dart';

import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/view_cashflow/recurring/recurring_card.dart';
import 'package:money/app/modules/home/sub_views/view_cashflow/recurring/recurring_payment.dart';

class PanelRecurring extends StatefulWidget {
  const PanelRecurring({
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
  State<PanelRecurring> createState() => _PanelRecurringState();
}

class _PanelRecurringState extends State<PanelRecurring> {
  late bool forIncomeTransaction;
  List<RecurringPayment> recurringPayments = [];

  @override
  void initState() {
    super.initState();
    forIncomeTransaction = widget.viewRecurringAs == CashflowViewAs.recurringIncomes;
    initRecurringTransactions(forIncome: forIncomeTransaction);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: getColorTheme(context).surface,
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
        },
      ),
    );
  }

  void findMonthlyRecurringPayments(
    List<Transaction> transactions,
    bool isIncomeTransaction,
  ) {
    // reset the content
    recurringPayments.clear();

    AccumulatorList<int, Transaction> groupTransactionsByPayeeId = AccumulatorList<int, Transaction>();
    AccumulatorList<int, int> groupMonthsListByPayeeId = AccumulatorList<int, int>();

    // Step 1: Group transactions by payeeId and record transaction months
    for (final transaction in transactions.where(
      (final t) =>
          (isIncomeTransaction && t.fieldAmount.value.toDouble() > 0) ||
          (isIncomeTransaction == false && t.fieldAmount.value.toDouble() <= 0),
    )) {
      int payeeId = transaction.fieldPayee.value;

      groupTransactionsByPayeeId.cumulate(payeeId, transaction);
      groupMonthsListByPayeeId.cumulate(
        payeeId,
        transaction.fieldDateTime.value!.month,
      );
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

  void initRecurringTransactions({required final bool forIncome}) {
    // get all transactions meeting the request of date and type
    bool whereClause(Transaction t) {
      return isBetweenOrEqual(t.fieldDateTime.value!.year, widget.minYear, widget.maxYear) &&
          (((forIncome == true && t.fieldAmount.value.toDouble() > 0) ||
              (forIncome == false && t.fieldAmount.value.toDouble() < 0)));
    }

    final flatTransactions = Data().transactions.getListFlattenSplits(whereClause: whereClause);

    // get all transaction Income | Expenses
    findMonthlyRecurringPayments(flatTransactions, forIncome);

    // Sort descending - biggest amount first
    if (widget.viewRecurringAs == CashflowViewAs.recurringIncomes) {
      recurringPayments.sort((a, b) => b.total.compareTo(a.total));
    }
    if (widget.viewRecurringAs == CashflowViewAs.recurringExpenses) {
      recurringPayments.sort((a, b) => a.total.compareTo(b.total));
    }
  }

  bool isMonthlyRecurrence(List<int> months) {
    if (widget.minYear == widget.maxYear) {
      return true;
    }
    // we can conclude that if paid more than 'n' months its a recurring monthly event
    return months.length == PreferenceController.to.cashflowRecurringOccurrences.value;
  }
}
