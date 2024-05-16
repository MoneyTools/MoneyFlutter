import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/widgets/vertical_line_with_tooltip.dart';

class MiniTimelineDaily extends StatelessWidget {
  final int yearStart;
  final int yearEnd;
  final Color? color;
  final double lineWidth;

  // [int = Days from millisecondFromEpoch], [double = amount]
  final List<Pair<int, double>> values;

  const MiniTimelineDaily({
    super.key,
    required this.yearStart,
    required this.yearEnd,
    required this.values,
    this.color,
    this.lineWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (final BuildContext context, final BoxConstraints constraints) {
      int numberOfYears = yearEnd - yearStart + 1;

      // X Ratio
      double numberOfDays = numberOfYears * 365.25;
      double xRatio = constraints.maxWidth / numberOfDays;

      // Y Ratio
      double maxValueFound = 0;
      for (final value in values) {
        maxValueFound = max(maxValueFound, value.second.abs());
      }
      double yRatio = constraints.maxHeight / maxValueFound;

      int offsetFromStartingPoint = values.first.first;

      List<Widget> bars = [];
      for (final value in values) {
        int oneDaySlot = value.first * Duration.millisecondsPerDay;

        bars.add(
          Positioned(
            left: xRatio * (value.first - offsetFromStartingPoint),
            child: VerticalLineWithTooltip(
              height: value.second.abs() * yRatio,
              width: lineWidth,
              color: colorBasedOnValue(value.second).withOpacity(0.5),
              tooltip:
                  '${dateToString(DateTime.fromMillisecondsSinceEpoch(oneDaySlot))}\n${doubleToCurrency(value.second)}',
            ),
          ),
        );
      }

      return Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: bars,
      );
    });
  }
}
