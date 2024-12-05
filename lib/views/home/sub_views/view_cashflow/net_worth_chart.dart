import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money/core/controller/preferences_controller.dart';
import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/widgets/charts/my_line_chart.dart';
import 'package:money/data/models/chart_event.dart';
import 'package:money/data/models/money_objects/categories/category.dart';
import 'package:money/data/models/money_objects/events/event.dart';
import 'package:money/data/models/money_objects/transactions/transactions.dart';
import 'package:money/data/storage/data/data.dart';
import 'package:money/views/home/sub_views/view_stocks/stock_chart.dart';

class NetWorthChart extends StatefulWidget {
  const NetWorthChart({super.key, required this.minYear, required this.maxYear});

  final int maxYear;
  final int minYear;

  @override
  NetWorthChartState createState() => NetWorthChartState();
}

class NetWorthChartState extends State<NetWorthChart> {
  final List<FlSpot> _yearMonthDataPoints = [];

  List<ChartEvent> _milestoneTransactions = [];
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();

    _transactions = Data().transactions.iterableList(includeDeleted: true).where((t) => t.isTransfer == false).toList();

    List<FlSpot> tmpDataPointsWithNetWorth = Transactions.cumulateTransactionPerYearMonth(_transactions);

    _yearMonthDataPoints.addAll(
      tmpDataPointsWithNetWorth.where(
        (entry) =>
            isBetweenOrEqual(DateTime.fromMillisecondsSinceEpoch(entry.x.toInt()).year, widget.minYear, widget.maxYear),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const marginLeft = 80.0;
    const marginBottom = 50.0;

    final transactionSubSet = _transactions
        .where(
          (Transaction t) => isBetweenOrEqual(
            t.fieldDateTime.value!.year,
            widget.minYear,
            widget.maxYear,
          ),
        )
        .toList();

    _milestoneTransactions = getMilestonesEvents(transactionSubSet);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: marginLeft, bottom: marginBottom),
          child: CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: PaintActivities(
              activities: _milestoneTransactions,
              minX: _yearMonthDataPoints.first.x,
              maxX: _yearMonthDataPoints.last.x,
            ),
          ),
        ),
        MyLineChart(
          dataPoints: _yearMonthDataPoints,
          showDots: false,
        ),
      ],
    );
  }
}

List<ChartEvent> getMilestonesEvents(final List<Transaction> transactions) {
  List<ChartEvent> milestoneTransactions = [];

  if (PreferenceController.to.netWorthEventThreshold.value == 0) {
    for (final Event event in Data().events.iterableList()) {
      final Category? category = Data().categories.get(event.fieldCategoryId.value);
      milestoneTransactions.add(
        ChartEvent(
          dates: DateRange(min: event.fieldDateBegin.value!),
          amount: 0,
          quantity: 1,
          colorBasedOnQuantity: false, // use Amount
          description: event.fieldName.value,
          color: category == null ? Colors.blue : category.getColorOrAncestorsColor(),
        ),
      );
    }
    return milestoneTransactions;
  }

  // Calculate Z-scores for outlier detection based on amount
  List<double> amounts = transactions.map((t) => t.fieldAmount.value.toDouble()).toList();
  if (amounts.isEmpty) {
    // nothing to work on;
    return [];
  }

  // Find outlier events
  double mean = amounts.reduce((a, b) => a + b) / amounts.length;
  double variance = amounts.map((amount) => (amount - mean) * (amount - mean)).reduce((a, b) => a + b) / amounts.length;
  double stdDev = sqrt(variance);

  List<double> zScores = amounts.map((amount) => stdDev == 0 ? 0.0 : (amount - mean) / stdDev).toList();

  for (int i = 0; i < transactions.length; i++) {
    double zScore = zScores[i];
    if (zScore.abs() >= PreferenceController.to.netWorthEventThreshold.value) {
      final t = transactions[i];
      milestoneTransactions.add(
        ChartEvent(
          dates: DateRange(min: t.fieldDateTime.value!),
          amount: t.fieldAmount.value.toDouble(),
          quantity: 1,
          colorBasedOnQuantity: false, // use Amount
          description: t.oneLinePayeeAndDescription,
        ),
      );
    }
  }
  milestoneTransactions.sort((a, b) => sortByDate(a.dates.min, b.dates.min, true));
  return milestoneTransactions;
}
