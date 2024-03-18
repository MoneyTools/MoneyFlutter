import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/widgets/center_message.dart';

class PairXY {
  num yValue = 0.0;
  String xText = '';

  PairXY(this.xText, this.yValue);
}

class Chart extends StatelessWidget {
  final List<PairXY> list;
  final String variableNameHorizontal;
  final String variableNameVertical;

  const Chart({
    super.key,
    required this.list,
    this.variableNameVertical = 'Y',
    this.variableNameHorizontal = 'X',
  });

  @override
  Widget build(final BuildContext context) {
    if (list.isEmpty) {
      return const CenterMessage(message: 'No chart to display');
    }
    final List<BarChartGroupData> barCharts = <BarChartGroupData>[];

    double maxY = 0.0;
    double minY = 0.0;

    for (int i = 0; i < list.length; i++) {
      final PairXY entry = list[i];
      maxY = max(maxY, entry.yValue.toDouble());
      minY = min(minY, entry.yValue.toDouble());
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
        maxY: roundToTheNextNaturalFit(maxY.toInt()).toDouble(),
        minY: minY == 0 ? 0 : -roundToTheNextNaturalFit(minY.toInt().abs()).toDouble(),
        barGroups: barCharts,
        backgroundColor: Colors.transparent,
        borderData: getBorders(minY, maxY),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(), // hide
          rightTitles: const AxisTitles(), // hide
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 80,
              getTitlesWidget: _buildLegendLeft,
              //interval: (maxY+minY.abs())/6,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: _buildLegendBottom,
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
                '${list[group.x].xText}\n${Currency.getAmountAsStringUsingCurrency(rod.toY)}',
                TextStyle(color: Theme.of(context).colorScheme.primary),
                textAlign: TextAlign.start,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLegendLeft(final double value, final TitleMeta meta) {
    final Widget widget = Text(
      Currency.getAmountAsStringUsingCurrency(value, decimalDigits: 0),
      textAlign: TextAlign.end,
      softWrap: false,
      style: const TextStyle(fontSize: 10),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: widget,
    );
  }

  Widget _buildLegendBottom(final double value, final TitleMeta meta) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxWidth: 60),
      child: Text(
        list[value.toInt()].xText,
        softWrap: true,
        style: const TextStyle(fontSize: 10),
      ),
    );
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

  FlBorderData getBorders(final double min, final double max) {
    return FlBorderData(
      show: true,
      border: Border(
          top: BorderSide(
            color: getHorizontalLineColorBasedOnValue(max),
          ),
          bottom: BorderSide(
            color: getHorizontalLineColorBasedOnValue(min),
          )),
    );
  }
}
