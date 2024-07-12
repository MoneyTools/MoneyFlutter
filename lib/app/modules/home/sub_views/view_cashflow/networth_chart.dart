// ignore_for_file: unnecessary_this

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/app/core/helpers/accumulator.dart';
import 'package:money/app/core/helpers/chart_helper.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/widgets/chart.dart';
import 'package:money/app/data/storage/data/data.dart';

class NetWorthChart extends StatefulWidget {
  const NetWorthChart({super.key, required this.minYear, required this.maxYear});

  final int maxYear;
  final int minYear;

  @override
  NetWorthChartState createState() => NetWorthChartState();
}

class NetWorthChartState extends State<NetWorthChart> {
  List<FlSpot> dataPoints = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();

    final AccumulatorSum<String, double> cumulateYearMonthBalance = AccumulatorSum<String, double>();

    final transactions = Data().transactions.iterableList(includeDeleted: true);

    for (final t in transactions) {
      String dateKey = '${t.dateTime.value!.year},${t.dateTime.value!.month.toString().padLeft(2, '0')}';
      cumulateYearMonthBalance.cumulate(dateKey, t.amount.value.toDouble());
    }

    List<FlSpot> tmpDataPoints = [];
    cumulateYearMonthBalance.getEntries().forEach(
      (entry) {
        final tokens = entry.key.split(',');
        DateTime dateForYearMonth = DateTime(int.parse(tokens[0]), int.parse(tokens[1]));
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

    dataPoints.addAll(
      tmpDataPointsWithNetWorht.where(
        (entry) =>
            isBetweenOrEqual(DateTime.fromMillisecondsSinceEpoch(entry.x.toInt()).year, widget.minYear, widget.maxYear),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          getLineChartBarData(dataPoints),
        ],
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(), // hide
          rightTitles: const AxisTitles(), // hide
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 80,
              getTitlesWidget: getWidgetChartAmount,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value == meta.min || value == meta.max) {
                  return const SizedBox();
                }
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text(
                  formatDate(date),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                ); // Format as HH:MM
              },
            ),
          ),
        ),
        borderData: getBorders(0, 0),
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}

String formatDate(DateTime date) {
  return DateFormat('yyyy\nMMM').format(date);
}
