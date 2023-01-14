import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class CategoryValue {
  String category = "";
  num value = 0.0;

  CategoryValue(this.category, this.value);
}

class WidgetBarChart extends StatelessWidget {
  final List<CategoryValue> list;

  const WidgetBarChart({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    var data = [
      {'category': '', 'amount': 0}, // TODO this is a hack, still don't know why I can just initialize directly
    ];
    data.clear(); // TODO part of the hack

    for (var entry in list) {
      data.add({'category': entry.category, 'amount': entry.value});
    }

    var w = 800.0;
    var h = 300.0;

    return Center(
      child: SizedBox(
          width: w,
          height: h,
          child: Chart(
            data: data,
            variables: {
              'category': Variable(accessor: (Map map) => map['category'] as String),
              'amount': Variable(accessor: (Map map) => map['amount'] as num),
            },
            elements: [IntervalElement()],
            axes: [
              Defaults.horizontalAxis,
              Defaults.verticalAxis,
            ],
          )),
    );
  }
}
