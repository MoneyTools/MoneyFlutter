import 'dart:math';
import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/money_model.dart';
import 'package:money/widgets/money_widget.dart';

class BarChartWidget extends StatelessWidget {
  final List<KeyValue> listAsAmount; // List of data with label and value
  final bool asIncome;

  const BarChartWidget({super.key, required this.listAsAmount, required this.asIncome});

  @override
  Widget build(BuildContext context) {
    // Sort the data by value in descending order
    listAsAmount.sort((a, b) => b.value.compareTo(a.value));

    final listAsPercentage = convertToPercentages(listAsAmount);

    // Extract top 3 values and calculate total value of others
    int topCategoryToShow = min(3, listAsAmount.length);

    const maxWidthOfBars = 100.0;

    final double otherSumPercentages =
        listAsPercentage.skip(topCategoryToShow).fold(0.0, (double prev, KeyValue curr) => prev + curr.value);

    final double otherSumValues =
        listAsAmount.skip(topCategoryToShow).fold(0.0, (double prev, KeyValue curr) => prev + curr.value);

    List<Widget> bars = [];

    for (int top = 0; top < topCategoryToShow; top++) {
      double percentage = listAsPercentage[top].value / 100;
      final barWidth = maxWidthOfBars * percentage;
      bars.add(_buildBar(barWidth, listAsAmount[top].key, listAsAmount[top].value, Colors.blue));
    }

    bars.add(_buildBar(maxWidthOfBars * otherSumPercentages / 100, 'Others', otherSumValues, Colors.grey));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: bars,
    );
  }

  Widget _buildBar(double width, String label, double value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: Text(
          label,
          style: const TextStyle(fontSize: 9),
          textAlign: TextAlign.justify,
          textWidthBasis: TextWidthBasis.longestLine,
          softWrap: false,
        )),
        Expanded(
          child: Row(
            children: [
              const Spacer(),
              Container(
                width: width,
                height: 10,
                color: color,
              ),
            ],
          ),
        ),
        Expanded(child: MoneyWidget(amountModel: MoneyModel(amount: value * (asIncome ? 1 : -1)), asTile: false)),
      ],
    );
  }
}
