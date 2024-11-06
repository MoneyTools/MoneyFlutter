import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/core/helpers/string_helper.dart';
import 'package:money/core/widgets/date_range_time_line.dart';
import 'package:money/core/widgets/gaps.dart';
import 'package:money/core/widgets/mini_timeline_daily.dart';
import 'package:money/data/models/money_objects/transactions/transactions.dart';

/// Widget to display a timeline chart of transactions.
///
/// This widget visualizes the sum of transactions over time, providing a graphical
/// representation of spending patterns. It uses a [MiniTimelineDaily] to display
/// daily sums and a [DateRangeTimeline] to show the overall date range.
class TransactionTimelineChart extends StatelessWidget {
  const TransactionTimelineChart({
    super.key,
    required this.transactions,
  });

  /// A list of transactions, potentially with splits flattened.
  final List<Transaction> transactions;

  @override
  Widget build(final BuildContext context) {
    // Handle empty transaction list
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions'));
    }

    // Calculate the date range of all transactions
    final DateRange dateRange = DateRange();
    for (final t in transactions) {
      dateRange.inflate(t.fieldDateTime.value);
    }

    // Calculate the maximum absolute transaction value for scaling the graph
    double maxValue = 0;
    final List<Pair<int, double>> sumByDays = Transactions.transactionSumByTime(transactions);
    for (final pair in sumByDays) {
      maxValue = max(maxValue, pair.second.abs());
    }

    // Extract start and end years for the timeline
    final int yearStart = dateRange.min!.year;
    final int yearEnd = dateRange.max!.year;

    // Define styling for the graph
    final borderColor = getColorTheme(context).onSecondaryContainer.withOpacity(0.3);
    final TextStyle textStyle = Theme.of(context).textTheme.labelSmall!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vertical axis labels
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(getAmountAsShorthandText(maxValue), style: textStyle),
                  Text(
                    getAmountAsShorthandText(maxValue / 2),
                    style: textStyle,
                  ),
                  Text('0.00', style: textStyle),
                ],
              ),
            ),
            // Timeline chart and date range
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Daily transaction sum timeline
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: borderColor,
                            width: 1.0,
                          ),
                          bottom: BorderSide(
                            color: borderColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: MiniTimelineDaily(
                        offsetStartingDay: sumByDays.first.first,
                        yearStart: yearStart,
                        yearEnd: yearEnd,
                        values: sumByDays,
                        lineWidth: 3,
                      ),
                    ),
                  ),
                  gapMedium(),
                  // Overall date range timeline
                  DateRangeTimeline(
                    startDate: dateRange.min!,
                    endDate: dateRange.max!,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
