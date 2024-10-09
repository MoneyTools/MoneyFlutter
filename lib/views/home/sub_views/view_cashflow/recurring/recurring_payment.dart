// ignore_for_file: unnecessary_this

import 'dart:math';

import 'package:money/core/helpers/accumulator.dart';
import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/core/widgets/distribution_bar.dart';
import 'package:money/data/models/money_objects/categories/category.dart';
import 'package:money/data/models/money_objects/transactions/transaction.dart';
import 'package:money/data/storage/data/data.dart';

class RecurringPayment {
  RecurringPayment({
    required this.payeeId,
    required this.forIncomeTransaction,
    required this.transactions,
  }) {
    total = 0.00;
    dateRangeFound = DateRange();
    categoryIdsAndSums = [];
    frequency = transactions.length;

    MapAccumulatorSum<int, int, double> payeeIdMonthAndSums = MapAccumulatorSum<int, int, double>();
    Map<int, AccumulatorSum<int, double>> payeeIdCategoryIdsAndSums = {};

    averagePerMonths = List.generate(12, (index) => Pair<int, double>(0, 0));

    for (final transaction in transactions) {
      total += transaction.fieldAmount.value.toDouble();
      dateRangeFound.inflate(transaction.fieldDateTime.value);

      /// Cumulate by [PayeeId].[month].[Sum]
      payeeIdMonthAndSums.cumulate(
        payeeId,
        transaction.fieldDateTime.value!.month,
        transaction.fieldAmount.value.toDouble(),
      );

      /// Rolling average per Month
      int transactionMonth = transaction.fieldDateTime.value!.month - 1;
      final Pair<int, double> pair = averagePerMonths[transactionMonth];
      if (pair.first == 0) {
        // first time
        averagePerMonths[transactionMonth] = Pair<int, double>(1, transaction.fieldAmount.value.toDouble());
      } else {
        averagePerMonths[transactionMonth] = Pair<int, double>(
          pair.first + 1,
          averageTwoNumbers(
            pair.second,
            transaction.fieldAmount.value.toDouble(),
          ),
        );
      }

      if (!payeeIdCategoryIdsAndSums.containsKey(payeeId)) {
        payeeIdCategoryIdsAndSums[payeeId] = AccumulatorSum<int, double>();
      }
      payeeIdCategoryIdsAndSums[payeeId]!.cumulate(
        transaction.fieldCategoryId.value,
        transaction.fieldAmount.value.toDouble(),
      );
    }

    // sum per month
    sumPerMonths = List.generate(12, (index) => 0);
    final AccumulatorSum<int, double> monthSums2 = payeeIdMonthAndSums.getLevel1(payeeId)!;
    monthSums2.values.forEach((int month, double sum) {
      sumPerMonths[month - 1] = sum.abs();
    });

    categoryIdsAndSums = convertMapToListOfPair<int, double>(
      payeeIdCategoryIdsAndSums[payeeId]!.values,
    );

    categoryDistribution = getTopDistributions(
      payment: this,
      asIncome: forIncomeTransaction,
      topN: 4,
    );
  }

  final bool forIncomeTransaction;
  final int payeeId;
  final List<Transaction> transactions;

  late List<Pair<int, double>> averagePerMonths;
  late List<Distribution> categoryDistribution;
  late List<Pair<int, double>> categoryIdsAndSums;
  late DateRange dateRangeFound;
  late int frequency;
  late List<double> sumPerMonths;
  late double total;

  double averageTwoNumbers(final double a, final double b) {
    // (-10 - -20) = -30 / 2 = -15
    if (a < 0 && b < 0) {
      return (a.abs() + b.abs()) / -2;
    }

    // (+10 + 20) = +30 / 2 = +15
    return (a + b) / 2;
  }

  List<Pair<int, double>> getListOfCategoryIdAndSum() {
    return categoryIdsAndSums;
  }

  List<Distribution> getTopDistributions({
    required RecurringPayment payment,
    required bool asIncome,
    required int topN,
  }) {
    final List<Pair<int, double>> list = payment.getListOfCategoryIdAndSum();
    // Sort descending
    if (asIncome) {
      list.sort((a, b) => b.second.compareTo(a.second));
    } else {
      list.sort((a, b) => a.second.compareTo(b.second));
    }

    List<Distribution> listForDistributionBar = [];

    // keep at most [n] number of items
    final int topCategoryToShow = min(topN, list.length);

    for (final categoryIdAndSum in list.take(topCategoryToShow)) {
      final Category? category = Data().categories.get(categoryIdAndSum.first);
      if (category == null) {
        listForDistributionBar.add(
          Distribution(
            title: '< no category >',
            amount: categoryIdAndSum.second,
          ),
        );
      } else {
        listForDistributionBar.add(
          Distribution(
            title: category.fieldName.value,
            color: category.getColorOrAncestorsColor(),
            amount: categoryIdAndSum.second,
          ),
        );
      }
    }
    return listForDistributionBar;
  }
}
