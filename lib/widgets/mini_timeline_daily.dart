import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';

class MiniTimelineDaily extends StatelessWidget {
  final int yearStart;
  final int yearEnd;
  final Color color;

  // [int = time in millisecond], [double = amount]
  final List<Pair<int, double>> values;
  final double height;

  const MiniTimelineDaily({
    super.key,
    required this.yearStart,
    required this.yearEnd,
    required this.values,
    this.color = Colors.blue,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    int numberOfYears = yearEnd - yearStart + 1;
    double numberOfDays = numberOfYears * 365.25;
    double maxValueFound = 0;
    for (final value in values) {
      maxValueFound = max(maxValueFound, value.second.abs());
    }
    double ratio = height / maxValueFound;
    for (final value in values) {
      value.second = value.second.abs() * ratio;
    }

    return CustomPaint(
      size: Size(500, height),
      painter: _MiniBarChartPainter(values, numberOfDays, color),
    );
  }
}

class _MiniBarChartPainter extends CustomPainter {
  final double numberOfDays;
  final List<Pair<int, double>> values;
  final Color color;

  _MiniBarChartPainter(
    this.values,
    this.numberOfDays,
    this.color,
  );

  @override
  bool shouldRepaint(_MiniBarChartPainter oldDelegate) {
    return false; //values != oldDelegate.values;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final paint = Paint();
    paint.color = color;
    paint.strokeWidth = 1;

    double xRatio = size.width / numberOfDays;

    for (final pair in values) {
      final double x = pair.first * xRatio;

      final startPoint = Offset(x, size.height);

      double v = pair.second;

      if (v < 1) {
        v = 1; // min height to see something
      }

      final endPoint = Offset(x, size.height - v);

      canvas.drawLine(startPoint, endPoint, paint);
    }
  }
}
