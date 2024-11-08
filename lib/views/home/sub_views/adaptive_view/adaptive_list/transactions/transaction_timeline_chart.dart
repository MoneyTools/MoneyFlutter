import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/core/helpers/date_helper.dart';
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

    List<PairXY> sumByPeriod = _calculateSumByPeriod();

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

  List<PairXY> _calculateSumByPeriod() {
    switch (_selectedScale) {
      // DAILY
      case TimelineScale.daily:
        return Transactions.transactionSumBy(
          widget.transactions,
          (date) => dateToString(
            DateTime(date.year, date.month, date.day),
          ),
        );

      // WEEKLY
      case TimelineScale.weekly:
        return Transactions.transactionSumBy(
          widget.transactions,
          (date) => dateToString(
            date.subtract(Duration(days: date.weekday)),
          ),
        );

      // MONTHLY
      case TimelineScale.monthly:
        return Transactions.transactionSumBy(
          widget.transactions,
          (date) => '${date.year}\n${date.month}',
        );

      // YEARLY
      case TimelineScale.yearly:
        return Transactions.transactionSumBy(
          widget.transactions,
          (date) => date.year.toString(),
        );
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
