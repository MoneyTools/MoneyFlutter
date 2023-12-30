import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money/helpers.dart';

class PairXY {
  num yValue = 0.0;
  String xText = '';

  PairXY(this.xText, this.yValue);
}

class WidgetBarChart extends StatelessWidget {
  final List<PairXY> list;
  final String variableNameHorizontal;
  final String variableNameVertical;

  const WidgetBarChart({
    super.key,
    required this.list,
    this.variableNameVertical = 'Y',
    this.variableNameHorizontal = 'X',
  });

  @override
  Widget build(final BuildContext context) {
    if (list.isEmpty) {
      return Text('No chart to display ${list.length}');
    }
    final List<BarChartGroupData> barCharts = <BarChartGroupData>[];

    for (int i = 0; i < list.length; i++) {
      final PairXY entry = list[i];
      final BarChartGroupData bar = BarChartGroupData(
        x: i,
        barRods: <BarChartRodData>[
          BarChartRodData(toY: entry.yValue.toDouble(), color: entry.yValue < 0 ? Colors.red : Colors.green),
        ],
      );

      barCharts.add(bar);
    }

    return BarChart(
      BarChartData(
        // maxY: 100,
        barGroups: barCharts,
        backgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(), // hide
          rightTitles: const AxisTitles(), // hide
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 80,
              // getTitlesWidget: _buildTitlesForLeftAxis,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: _buildBottomLegend,
              interval: 1,
            ),
          ),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (final double value) {
            return FlLine(
              color: getHorizontalLineColorBasedOnValue(value),
              strokeWidth: 1, // Set the thickness of the grid lines
            );
          },
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Theme.of(context).colorScheme.secondaryContainer,
            tooltipRoundedRadius: 8,
            getTooltipItem: (
              final BarChartGroupData group,
              final int groupIndex,
              final BarChartRodData rod,
              final int rodIndex,
            ) {
              return BarTooltipItem(
                '${list[group.x].xText}\n${getCurrencyText(rod.toY)}',
                TextStyle(color: Theme.of(context).colorScheme.primary),
                textAlign: TextAlign.start,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomLegend(final double value, final TitleMeta meta) {
    return Text(list[value.toInt()].xText);
  }

  Color getHorizontalLineColorBasedOnValue(final double value) {
    if (value > 0) {
      return Colors.green.withOpacity(0.2);
    }
    if (value < 0) {
      return Colors.red.withOpacity(0.2);
    }
    // value == 0
    return Colors.grey.withOpacity(0.8);
  }
}
