import 'dart:math';
import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/money_model.dart';
import 'package:money/models/money_objects/categories/category.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/widgets/circle.dart';
import 'package:money/widgets/money_widget.dart';

class BarChartWidget extends StatelessWidget {
  final List<KeyValue> listAsAmount; // List of data with label and value
  final bool asIncome;

  const BarChartWidget({super.key, required this.listAsAmount, required this.asIncome});

  @override
  Widget build(BuildContext context) {
    // Sort the data by value in descending order
    listAsAmount.sort((a, b) => b.value.compareTo(a.value));

    // Extract top 3 values and calculate total value of others
    int topCategoryToShow = min(3, listAsAmount.length);

    final double otherSumValues =
        listAsAmount.skip(topCategoryToShow).fold(0.0, (double prev, KeyValue curr) => prev + curr.value);

    List<Widget> bars = [];

    for (int top = 0; top < topCategoryToShow; top++) {
      final Category? category = Data().categories.getByName(listAsAmount[top].key);
      if (category != null) {
        bars.add(
          _buildBar(
            category.name.value,
            category.getColorWidget(),
            listAsAmount[top].value,
          ),
        );
      }
    }

    if (otherSumValues > 0) {
      bars.add(
        _buildBar(
          'Others',
          MyCircle(
            colorFill: Colors.grey.withOpacity(0.5),
            size: 10,
          ),
          otherSumValues,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: bars,
    );
  }

  Widget _buildBar(String label, Widget colorWidget, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 9),
              textAlign: TextAlign.justify,
              textWidthBasis: TextWidthBasis.longestLine,
              softWrap: false,
            )),
        colorWidget,
        Expanded(child: MoneyWidget(amountModel: MoneyModel(amount: value * (asIncome ? 1 : -1)), asTile: false)),
      ],
    );
  }
}
