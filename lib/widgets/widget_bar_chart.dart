import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class WidgetBarChart extends StatelessWidget {
  const WidgetBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 200,
        width: 400,
        child: Chart(
          data: const [
            {'category': 'Restaurant', 'amount': 275},
            {'category': 'Car', 'amount': 115},
            {'category': 'School', 'amount': 120},
            {'category': 'Taxes', 'amount': 350},
            {'category': 'Travel', 'amount': 150},
          ],
          variables: {
            'category': Variable(
              accessor: (Map map) => map['category'] as String,
            ),
            'amount': Variable(
              accessor: (Map map) => map['amount'] as num,
            ),
          },
          elements: [IntervalElement()],
          axes: [
            Defaults.horizontalAxis,
            Defaults.verticalAxis,
          ],
        ));
  }
}
