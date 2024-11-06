import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/helpers/string_helper.dart'; // Make sure this import is correct

enum TimelineScale { daily, weekly, monthly, yearly }

class TimeLineChart extends StatelessWidget {
  const TimeLineChart({
    super.key,
    required this.values, // Now takes List<Pair<DateTime, double>>
    required this.dateFormat, // For formatting date labels
  });

  final String dateFormat;
  final List<Pair<DateTime, double>> values;

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barChartData = values.asMap().entries.map((entry) {
      final int index = entry.key;
      final pair = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: pair.second,
            color: pair.second >= 0 ? Colors.green : Colors.red,
            width: 10,
          ),
        ],
      );
    }).toList();

    double maxY = values.map((e) => e.second).fold(0.0, (max, current) => max > current ? max : current);
    double minY = values.map((e) => e.second).fold(0.0, (min, current) => min < current ? min : current);

    maxY = maxY * (maxY > 0 ? 1.1 : 0.9);
    minY = minY * (minY < 0 ? 1.1 : 0.9);

    return BarChart(
      swapAnimationDuration: Duration.zero,
      BarChartData(
        barGroups: barChartData,
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: minY,
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 80, // Reserve space for left titles
              getTitlesWidget: (value, meta) {
                return Text(
                  getAmountAsShorthandText(value),
                  textAlign: TextAlign.right,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index < 0 || index >= values.length) {
                  return const SizedBox.shrink();
                }
                final dateTime = values[index].first;
                final formattedDate = DateFormat(dateFormat).format(dateTime);
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 10,
                  child: Text(
                    formattedDate,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
      ),
    );
  }
}

class TimeSeriesData {
  // Helper class if you need it
  TimeSeriesData(this.time, this.value);

  final DateTime time;
  final double value;
}
