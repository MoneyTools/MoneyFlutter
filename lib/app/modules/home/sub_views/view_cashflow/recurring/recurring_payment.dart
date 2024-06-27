// ignore_for_file: unnecessary_this

import 'dart:math';

import 'package:money/app/core/helpers/accumulator.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/widgets/distribution_bar.dart';
import 'package:money/app/data/models/date_range.dart';
import 'package:money/app/data/models/money_objects/categories/category.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';

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
      total += transaction.amount.value.toDouble();
      dateRangeFound.inflate(transaction.dateTime.value);

      /// Cumulate by [PayeeId].[month].[Sum]
      payeeIdMonthAndSums.cumulate(
        payeeId,
        transaction.dateTime.value!.month,
        transaction.amount.value.toDouble(),
      );

      /// Rolling average per Month
      int transactionMonth = transaction.dateTime.value!.month - 1;
      final Pair<int, double> pair = averagePerMonths[transactionMonth];
      if (pair.first == 0) {
        // first time
        averagePerMonths[transactionMonth] = Pair<int, double>(1, transaction.amount.value.toDouble());
      } else {
        averagePerMonths[transactionMonth] = Pair<int, double>(
          pair.first + 1,
          averageTwoNumbers(
            pair.second,
            transaction.amount.value.toDouble(),
          ),
        );
      }

      if (!payeeIdCategoryIdsAndSums.containsKey(payeeId)) {
        payeeIdCategoryIdsAndSums[payeeId] = AccumulatorSum<int, double>();
      }
      payeeIdCategoryIdsAndSums[payeeId]!.cumulate(
        transaction.categoryId.value,
        transaction.amount.value.toDouble(),
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
  final int payeeId;
  final List<Transaction> transactions;
  final bool forIncomeTransaction;

  late double total;
  late DateRange dateRangeFound;
  late int frequency;
  late List<double> sumPerMonths;
  late List<Pair<int, double>> averagePerMonths;
  late List<Pair<int, double>> categoryIdsAndSums;
  late List<Distribution> categoryDistribution;

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
            title: category.name.value,
            color: category.getColorOrAncestorsColor(),
            amount: categoryIdAndSum.second,
          ),
        );
      }
    }
    return listForDistributionBar;
  }

  List<Pair<int, double>> getListOfCategoryIdAndSum() {
    return categoryIdsAndSums;
  }

  double averageTwoNumbers(final double a, final double b) {
    // (-10 - -20) = -30 / 2 = -15
    if (a < 0 && b < 0) {
      return (a.abs() + b.abs()) / -2;
    }

    // (+10 + 20) = +30 / 2 = +15
    return (a + b) / 2;
  }
}
