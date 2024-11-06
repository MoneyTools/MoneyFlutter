import 'package:flutter/material.dart';
import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/core/helpers/string_helper.dart';
import 'package:money/core/widgets/timeline_chart.dart'; // Assuming this is your custom chart widget
import 'package:money/data/models/money_objects/transactions/transactions.dart';

/// Widget to display a timeline chart of transactions.
class TransactionTimelineChart extends StatefulWidget {
  const TransactionTimelineChart({
    super.key,
    required this.transactions,
  });

  final List<Transaction> transactions;

  @override
  State<TransactionTimelineChart> createState() => _TransactionTimelineChartState();
}

class _TransactionTimelineChartState extends State<TransactionTimelineChart> {
  TimelineScale _selectedScale = TimelineScale.yearly;

  @override
  Widget build(final BuildContext context) {
    if (widget.transactions.isEmpty) {
      return const Center(child: Text('No transactions'));
    }

    final dateRange = DateRange();
    for (final t in widget.transactions) {
      dateRange.inflate(t.fieldDateTime.value);
    }

    List<Pair<DateTime, double>> sumByPeriod = _calculateSumByPeriod(dateRange);

    return Column(
      children: [
        DropdownButton<TimelineScale>(
          value: _selectedScale,
          onChanged: (TimelineScale? newValue) {
            setState(() {
              _selectedScale = newValue!;
            });
          },
          items: TimelineScale.values.map<DropdownMenuItem<TimelineScale>>((TimelineScale value) {
            return DropdownMenuItem<TimelineScale>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TimeLineChart(
              values: sumByPeriod,
              dateFormat: _getDateFormat(_selectedScale),
            ),
          ),
        ),
      ],
    );
  }

  List<Pair<DateTime, double>> _calculateSumByPeriod(DateRange dateRange) {
    switch (_selectedScale) {
      case TimelineScale.daily:
        return Transactions.transactionSumDaily(widget.transactions);
      case TimelineScale.weekly:
        return Transactions.transactionSumWeekly(widget.transactions);
      case TimelineScale.monthly:
        return Transactions.transactionSumMonthly(widget.transactions);
      case TimelineScale.yearly:
        return Transactions.transactionSumByYearly(widget.transactions);
    }
  }

  String _getDateFormat(TimelineScale scale) {
    switch (scale) {
      case TimelineScale.daily:
        return 'dd\nMMM';
      case TimelineScale.weekly:
        return 'dd\nMMM';
      case TimelineScale.monthly:
        return 'MMM\nyyyy';
      case TimelineScale.yearly:
        return 'yyyy';
    }
  }
}

class ValueAxisLabels extends StatelessWidget {
  const ValueAxisLabels({
    super.key,
    required this.maxValue,
    required this.textStyle,
  });

  final double maxValue;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(getAmountAsShorthandText(maxValue), style: textStyle),
        Text(getAmountAsShorthandText(maxValue / 2), style: textStyle),
        Text('0.00', style: textStyle),
      ],
    );
  }
}
