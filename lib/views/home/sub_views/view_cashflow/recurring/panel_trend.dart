import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money/core/controller/preferences_controller.dart';
import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/core/widgets/chart.dart';
import 'package:money/core/widgets/money_widget.dart';
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

  @override
  void initState() {
    super.initState();
    yearCategoryIncomeExpenseSums = RecurringExpenses.getSumByIncomeExpenseByYears(widget.minYear, widget.maxYear);

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
    final years = yearCategoryIncomeExpenseSums.keys.toList()..sort();

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
          getTitlesWidget: (value, meta) {
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
