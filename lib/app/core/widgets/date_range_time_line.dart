import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';

class DateRangeTimeline extends StatelessWidget {
  const DateRangeTimeline({
    required this.startDate,
    required this.endDate,
    super.key,
    this.showTicks = true,
  });

  final DateTime endDate;
  final bool showTicks;
  final DateTime startDate;

  @override
  Widget build(BuildContext context) {
    // Calculate the number of years between the start and end dates
    int numYears = (endDate.year - startDate.year) + 1;
    TextStyle style = getTextTheme(context).labelSmall!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTicks)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ticks(numYears),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Start year
            Text('${startDate.year}', style: style),

            // Number of years
            Text('$numYears years', style: style),

            // End year
            Text('${endDate.year}', style: style),
          ],
        ),
      ],
    );
  }
}

List<Widget> ticks(final int numberOfTicks) {
  List<Widget> widgets = [];

  for (int tick = 0; tick < numberOfTicks; tick++) {
    widgets.add(
      Container(
        width: 1,
        height: 5,
        decoration: BoxDecoration(
          // shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.5),
        ),
      ),
    );
  }
  return widgets;
}
