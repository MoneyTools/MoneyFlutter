import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/data/models/money_model.dart';
import 'package:money/app/data/models/money_objects/categories/category.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/core/widgets/circle.dart';
import 'package:money/app/core/widgets/money_widget.dart';

class BarChartWidget extends StatelessWidget {
  final List<KeyValue> listCategoryNameToAmount; // List of data with label and value
  final bool asIncome;

  const BarChartWidget({super.key, required this.listCategoryNameToAmount, required this.asIncome});

  @override
  Widget build(BuildContext context) {
    // Sort the data by value in descending order
    listCategoryNameToAmount.sort((a, b) => b.value.compareTo(a.value));

    // Extract top 3 values and calculate total value of others
    int topCategoryToShow = min(3, listCategoryNameToAmount.length);

    final double otherSumValues =
        listCategoryNameToAmount.skip(topCategoryToShow).fold(0.0, (double prev, KeyValue curr) => prev + curr.value);

    List<Widget> bars = [];

    for (int top = 0; top < topCategoryToShow; top++) {
      final Category? category = Data().categories.get(listCategoryNameToAmount[top].key);
      if (category != null) {
        bars.add(
          _buildBar(
            category.name.value,
            category.getColorWidget(),
            listCategoryNameToAmount[top].value,
          ),
        );
      }
    }

    if (otherSumValues > 0) {
      bars.add(
        _buildBar(
          'Others',
          const MyCircle(
            colorFill: Colors.grey,
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
