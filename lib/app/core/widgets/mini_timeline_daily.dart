import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/vertical_line_with_tooltip.dart';

class MiniTimelineDaily extends StatelessWidget {
  const MiniTimelineDaily({
    required this.yearStart,
    required this.yearEnd,
    required this.values,
    required this.offsetStartingDay,
    super.key,
    this.color,
    this.lineWidth = 2,
  });

  final Color? color;
  final double lineWidth;

  /// X values are using days from 1970, use this offset to bring back the X scaling to location
  /// that match the desired UX, supplying the offset days of the first element in the values will start
  /// the graph on the left side of Zero
  final int offsetStartingDay;

  // [int = Days from millisecondFromEpoch], [double = amount]
  final List<Pair<int, double>> values;

  final int yearEnd;
  final int yearStart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
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

        List<Widget> bars = [];
        for (final value in values) {
          int oneDaySlot = value.first * Duration.millisecondsPerDay;

          bars.add(
            Positioned(
              left: xRatio * (value.first - offsetStartingDay),
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
      },
    );
  }
}
