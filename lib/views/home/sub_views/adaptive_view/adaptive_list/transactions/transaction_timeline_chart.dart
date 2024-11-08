import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/core/widgets/chart.dart';
import 'package:money/core/widgets/gaps.dart';
import 'package:money/core/widgets/icon_button.dart';
import 'package:money/data/models/money_objects/currencies/currency.dart';
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

enum TimelineScale { daily, weekly, monthly, yearly }

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

    List<PairXY> sumByPeriod = _calculateSumByPeriod(dateRange);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
            gapMedium(),
            MyIconButton(
              icon: Icons.copy_all_outlined,
              onPressed: () {
                _copyToClipboard(sumByPeriod);
              },
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Chart(
              list: sumByPeriod,
            ),
          ),
        ),
      ],
    );
  }

  List<PairXY> _calculateSumByPeriod(DateRange dateRange) {
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

  void _copyToClipboard(List<PairXY> data) {
    final String clipboardData =
        data.map((pair) => '${pair.xText} : ${Currency.getAmountAsStringUsingCurrency(pair.yValue)}').join('\n');
    Clipboard.setData(ClipboardData(text: clipboardData));
    // Optional: Show a snackbar to confirm copy
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }
}
