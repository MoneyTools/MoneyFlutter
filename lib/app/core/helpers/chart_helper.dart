import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// dataPoints will be sorted by date ascending
LineChartBarData getLineChartBarData(final List<FlSpot> dataPoints) {
  dataPoints.sort((a, b) => a.x.compareTo(b.x));

  Color color = Colors.grey;

  if (dataPoints.length >= 2) {
    color = dataPoints.last.y >= dataPoints.first.y ? Colors.green : Colors.red;
  }

  return LineChartBarData(
    spots: dataPoints,
    isCurved: false,
    color: color,
    barWidth: 1,
    belowBarData: BarAreaData(
      show: true,
      gradient: LinearGradient(
        colors: [
          color.withAlpha(100), // top
          color.withAlpha(10), // bottom
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),

    dotData: const FlDotData(show: false), // Hide dots at endpoints
  );
}
