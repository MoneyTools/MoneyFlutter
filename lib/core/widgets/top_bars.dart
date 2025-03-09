import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/widgets/circle.dart';
import 'package:money/core/widgets/money_widget.dart';
import 'package:money/data/models/money_objects/categories/category.dart';
import 'package:money/data/storage/data/data.dart';

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({
    required this.listCategoryNameToAmount,
    required this.asIncome,
    super.key,
  });

  final bool asIncome;
  final List<PairIntDouble>
  listCategoryNameToAmount; // List of data with label and value

  @override
  Widget build(BuildContext context) {
    // Sort the data by value in descending order
    listCategoryNameToAmount.sort(
      (PairIntDouble a, PairIntDouble b) => b.value.compareTo(a.value),
    );

    // Extract top 3 values and calculate total value of others
    final int topCategoryToShow = min(3, listCategoryNameToAmount.length);

    final double otherSumValues = listCategoryNameToAmount
        .skip(topCategoryToShow)
        .fold(
          0.0,
          (double prev, PairIntDouble current) => prev + current.value,
        );

    final List<Widget> bars = <Widget>[];

    for (int top = 0; top < topCategoryToShow; top++) {
      final Category? category = Data().categories.get(
        listCategoryNameToAmount[top].key,
      );
      if (category != null) {
        bars.add(
          _buildBar(
            category.fieldName.value,
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
          const MyCircle(colorFill: Colors.grey, size: 10),
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
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 9),
            textAlign: TextAlign.justify,
            textWidthBasis: TextWidthBasis.longestLine,
            softWrap: false,
          ),
        ),
        colorWidget,
        Expanded(
          child: MoneyWidget(
            amountModel: MoneyModel(amount: value * (asIncome ? 1 : -1)),
          ),
        ),
      ],
    );
  }
}
