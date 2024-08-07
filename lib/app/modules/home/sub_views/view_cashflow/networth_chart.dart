// ignore_for_file: unnecessary_this

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/accumulator.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/widgets/charts/my_line_chart.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/view_stocks/stock_chart.dart';

class NetWorthChart extends StatefulWidget {
  const NetWorthChart({super.key, required this.minYear, required this.maxYear});

  final int maxYear;
  final int minYear;

  @override
  NetWorthChartState createState() => NetWorthChartState();
}

class NetWorthChartState extends State<NetWorthChart> {
  final List<FlSpot> _dataPoints = [];

  List<ChartEvent> _outliers = [];

  @override
  void initState() {
    super.initState();

    final AccumulatorSum<String, double> cumulateYearMonthBalance = AccumulatorSum<String, double>();

    final List<Transaction> transactions = Data().transactions.iterableList(includeDeleted: true).toList();
    List<double> amounts = [];
    for (final t in transactions) {
      String dateKey = dateToString(t.fieldDateTime.value);

      cumulateYearMonthBalance.cumulate(dateKey, t.fieldAmount.value.toDouble());
    }
    // Calculate Z-scores for outlier detection based on amount
    amounts = transactions.map((t) => t.fieldAmount.value.toDouble()).toList();

    // Find outlier events
    double mean = amounts.reduce((a, b) => a + b) / amounts.length;
    double variance =
        amounts.map((amount) => (amount - mean) * (amount - mean)).reduce((a, b) => a + b) / amounts.length;
    double stdDev = sqrt(variance);

    List<double> zScores = amounts.map((amount) => stdDev == 0 ? 0.0 : (amount - mean) / stdDev).toList();

    _outliers = [];

    for (int i = 0; i < transactions.length; i++) {
      double zScore = zScores[i];
      if (zScore.abs() > 10) {
        _outliers.add(
          ChartEvent(
            date: transactions[i].fieldDateTime.value!,
            amount: transactions[i].fieldAmount.value.toDouble(),
            quantity: 1,
            colorBasedOnQuantity: false, // use Amount
            description: '${transactions[i].getPayeeOrTransferCaption()}\n${transactions[i].categoryAsString}',
          ),
        );
      }
    }
    _outliers.sort((a, b) => sortByDate(a.date, b.date, true));

    List<FlSpot> tmpDataPoints = [];
    cumulateYearMonthBalance.getEntries().forEach(
      (entry) {
        final tokens = entry.key.split('-');
        DateTime dateForYearMonth = DateTime(int.parse(tokens[0]), int.parse(tokens[1]), int.parse(tokens[2]));
        tmpDataPoints.add(FlSpot(dateForYearMonth.millisecondsSinceEpoch.toDouble(), entry.value));
      },
    );

    tmpDataPoints.sort((a, b) => a.x.compareTo(b.x));

    double netWorth = 0;
    List<FlSpot> tmpDataPointsWithNetWorht = [];
    for (final dp in tmpDataPoints) {
      netWorth += dp.y;
      tmpDataPointsWithNetWorht.add(FlSpot(dp.x, netWorth));
    }

    _dataPoints.addAll(
      tmpDataPointsWithNetWorht.where(
        (entry) =>
            isBetweenOrEqual(DateTime.fromMillisecondsSinceEpoch(entry.x.toInt()).year, widget.minYear, widget.maxYear),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const marginLeft = 80.0;
    const marginBottom = 50.0;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: marginLeft, bottom: marginBottom),
          child: CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: PaintActivities(
              activities: _outliers,
              minX: _dataPoints.first.x,
              maxX: _dataPoints.last.x,
            ),
          ),
        ),
        MyLineChart(
          dataPoints: _dataPoints,
          showDots: false,
        ),
      ],
    );
  }
}
