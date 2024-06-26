import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/widgets/center_message.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/money_objects/currencies/currency.dart';

FlBorderData getBorders(final double min, final double max) {
  return FlBorderData(
    show: true,
    border: Border(
      top: BorderSide(
        color: getHorizontalLineColorBasedOnValue(max),
      ),
      bottom: BorderSide(
        color: getHorizontalLineColorBasedOnValue(min),
      ),
    ),
  );
}

Color getHorizontalLineColorBasedOnValue(final double value) {
  return colorBasedOnValue(value).withOpacity(0.3);
}

Widget getWidgetChartAmount(final double value, final TitleMeta meta) {
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

class Chart extends StatelessWidget {
  const Chart({
    super.key,
    required this.list,
    this.variableNameVertical = 'Y',
    this.variableNameHorizontal = 'X',
    this.currency = Constants.defaultCurrency,
  });
  final List<PairXY> list;
  final String variableNameHorizontal;
  final String variableNameVertical;
  final String currency;

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
          BarChartRodData(
            toY: entry.yValue.toDouble(),
            color: entry.yValue < 0 ? Colors.red : Colors.green,
          ),
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
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 80,
              getTitlesWidget: getWidgetChartAmount,
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
            getTooltipColor: (BarChartGroupData group) => getColorTheme(context).secondaryContainer,
            tooltipRoundedRadius: 8,
            getTooltipItem: (
              final BarChartGroupData group,
              final int groupIndex,
              final BarChartRodData rod,
              final int rodIndex,
            ) {
              return BarTooltipItem(
                getTooltipText(group, rod),
                TextStyle(color: getColorTheme(context).primary),
                textAlign: TextAlign.start,
              );
            },
          ),
          touchCallback: (
            final FlTouchEvent event,
            final BarTouchResponse? barTouchResponse,
          ) {
            if (event is FlLongPressStart) {
              if (barTouchResponse != null) {
                if (barTouchResponse.spot != null) {
                  HapticFeedback.lightImpact();
                  copyToClipboardAndInformUser(
                    context,
                    getTooltipText(
                      barTouchResponse.spot!.touchedBarGroup,
                      barTouchResponse.spot!.touchedRodData,
                    ),
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }

  String getTooltipText(BarChartGroupData group, BarChartRodData rod) =>
      '${list[group.x].xText}\n${Currency.getAmountAsStringUsingCurrency(rod.toY, iso4217code: currency)}';

  Widget _buildLegendBottom(final double value, final TitleMeta meta) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxWidth: 60),
      child: Text(
        list[value.toInt()].xText,
        softWrap: true,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }
}

class PairXY {
  PairXY(this.xText, this.yValue);
  String xText = '';
  num yValue = 0.0;
}
