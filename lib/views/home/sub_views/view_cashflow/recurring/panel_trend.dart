import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money/core/controller/preferences_controller.dart';
import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/core/widgets/chart.dart';
import 'package:money/core/widgets/money_widget.dart';
import 'package:money/data/models/money_model.dart';
import 'package:money/views/home/sub_views/view_cashflow/recurring/recurring_expenses.dart';

class PanelTrend extends StatefulWidget {
  const PanelTrend({
    super.key,
    required this.dateRangeSearch,
    required this.minYear,
    required this.maxYear,
    required this.viewRecurringAs,
  });

  final DateRange dateRangeSearch;
  final int maxYear;
  final int minYear;
  final CashflowViewAs viewRecurringAs;

  @override
  State<PanelTrend> createState() => _PanelTrendState();

  int get numberOfYears => max(1, maxYear - minYear);
}

class _PanelTrendState extends State<PanelTrend> {
  double maxY = 0;
  double minY = 0;
  Map<int, RecurringExpenses> yearCategoryIncomeExpenseSums = {};
  List<int> years = [];

  @override
  void initState() {
    super.initState();
    yearCategoryIncomeExpenseSums = RecurringExpenses.getSumByIncomeExpenseByYears(widget.minYear, widget.maxYear);
    years = yearCategoryIncomeExpenseSums.keys.toList()..sort();

    maxY = 0;
    minY = 0;

    for (final yearData in yearCategoryIncomeExpenseSums.values) {
      maxY = max(max(maxY, yearData.sumExpense), yearData.sumIncome);
      minY = min(min(minY, yearData.sumExpense), yearData.sumIncome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipColor: (group) => Colors.black,
            fitInsideVertically: true,
            fitInsideHorizontally: true,
            maxContentWidth: 300,
            getTooltipItem: (BarChartGroupData group, int groupIndex, BarChartRodData rod, int rodIndex) {
              final int year = years[groupIndex];
              final RecurringExpenses yearData = yearCategoryIncomeExpenseSums[year]!;
              final double profit = yearData.sumIncome + yearData.sumExpense;
              return BarTooltipItem(
                year.toString(),
                textAlign: TextAlign.end,
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                children: [
                  TextSpan(
                    text: '\nRevenue\t${MoneyModel(amount: yearData.sumIncome).toShortHand()}',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: '\nExpense\t${MoneyModel(amount: yearData.sumExpense).toShortHand()}',
                    style: TextStyle(
                      color: Colors.red.shade100,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: '\n${profit > 0 ? 'Profit' : 'Loss'}\t${MoneyModel(amount: profit).toShortHand()}',
                    style: TextStyle(
                      color: profit > 0 ? Colors.blue : Colors.orange,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ],
              );
            },
          ),
          touchCallback: (event, response) {
            // Optional: Add custom touch handling here
          },
          handleBuiltInTouches: true,
        ),
        barGroups: _buildBarGroups(),
        alignment: BarChartAlignment.spaceEvenly,
        maxY: maxY * 1.1, // add 10%
        minY: minY * 1.1, // add 10%
        backgroundColor: Colors.transparent,
        borderData: getBorders(minY, maxY),
        titlesData: _buildTitlesData(),
        gridData: Chart.getChartGridData(),
      ),
    );
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
        ),
      ),
    );
  }

  Color getHorizontalLineColorBasedOnValue(final double value) {
    return colorBasedOnValue(value).withValues(alpha: 0.3);
  }

  // Data for the chart
  List<BarChartGroupData> _buildBarGroups() {
    final List<int> years = yearCategoryIncomeExpenseSums.keys.toList()..sort();

    return List.generate(years.length, (index) {
      final int year = years[index];
      final RecurringExpenses yearData = yearCategoryIncomeExpenseSums[year]!;
      final double profit = (yearData.sumIncome + yearData.sumExpense);
      return BarChartGroupData(
        groupVertically: true,
        x: index,
        barRods: [
          // Negative Bar
          BarChartRodData(
            fromY: 0,
            toY: yearData.sumIncome,
            color: getTextColorToUse(yearData.sumIncome)!.withAlpha(120),
            width: 20,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          ),
          BarChartRodData(
            fromY: 0,
            toY: yearData.sumExpense,
            color: getTextColorToUse(yearData.sumExpense)!.withAlpha(120),
            width: 20,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
          ),
          BarChartRodData(
            fromY: 0,
            toY: profit,
            color: profit > 0 ? Colors.blue : Colors.orange,
            width: 10,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(0)),
          ),
        ],
        barsSpace: 0,
      );
    });
  }

  // Titles on the x-axis
  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 120,
          getTitlesWidget: (value, meta) {
            return MoneyWidget.fromDouble(value);
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (final double value, final TitleMeta meta) {
            final years = yearCategoryIncomeExpenseSums.keys.toList()..sort();
            if (value.toInt() >= years.length) {
              return const Text('');
            }
            return Text(
              years[value.toInt()].toString(),
              style: const TextStyle(fontSize: 10),
            );
          },
          interval: 1,
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}