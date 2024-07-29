import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/app/core/helpers/chart_helper.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/chart.dart';

class MyLineChart extends StatelessWidget {
  const MyLineChart({
    super.key,
    required this.dataPoints,
    required this.showDots,
  });

  final List<FlSpot> dataPoints;
  final bool showDots;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          getLineChartBarData(dataPoints, showDots: showDots),
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
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideVertically: true,
            fitInsideHorizontally: true,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final date = DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt());
                return LineTooltipItem(
                  '${dateToString(date)}\n${doubleToCurrency(touchedSpot.y)}',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
          // touchCallback: (LineTouchResponse touchResponse) {},
          handleBuiltInTouches: true,
        ),
      ),
    );
  }
}

String formatDate(DateTime date) {
  return DateFormat('yyyy\nMMM').format(date);
}
