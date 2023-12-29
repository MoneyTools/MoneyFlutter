import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryValue {
  String category = '';
  num value = 0.0;

  CategoryValue(this.category, this.value);
}

class WidgetBarChart extends StatelessWidget {
  final List<CategoryValue> list;
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
      final CategoryValue entry = list[i];
      final BarChartGroupData bar = BarChartGroupData(
        x: i,
        barRods: <BarChartRodData>[
          BarChartRodData(toY: entry.value.toDouble()),
        ],
      );

      barCharts.add(bar);
    }

    return BarChart(
      BarChartData(
        // maxY: 100,
        backgroundColor: Colors.transparent,
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
              color: Theme.of(context).colorScheme.outline,
              strokeWidth: 1, // Set the thickness of the grid lines
            );
          },
        ),
        barGroups: barCharts,
        barTouchData: BarTouchData(
          enabled: true,
          // touchTooltipData: BarTouchTooltipData(
          //   tooltipRoundedRadius: 8,
          //   getTooltipItem: _tooltipItem,
          // ),
        ),
      ),
    );
  }

  Widget _buildBottomLegend(final double value, final TitleMeta meta) {
    return Text(list[value.toInt()].category);
  }
}
