import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../helpers.dart';

class CategoryValue {
  String category = '';
  num value = 0.0;

  CategoryValue(this.category, this.value);
}

class WidgetBarChart extends StatelessWidget {
  final List<CategoryValue> list;
  final String variableNameHorizontal;
  final String variableNameVertical;

  const WidgetBarChart({
    super.key,
    required this.list,
    this.variableNameVertical = 'Y',
    this.variableNameHorizontal = 'X',
  });

  @override
  Widget build(BuildContext context) {
    var data = [
      {variableNameHorizontal: '', variableNameVertical: 0}, // TODO this is a hack, still don't know why I can just initialize directly
    ];
    data.clear(); // TODO part of the hack

    for (var entry in list) {
      data.add({variableNameHorizontal: entry.category, variableNameVertical: entry.value});
    }

    var w = 800.0;
    var h = 300.0;

    return Center(
      child: SizedBox(
          width: w,
          height: h,
          child: Chart(
            data: data,
            marks: [IntervalMark()],
            variables: {
              variableNameHorizontal: Variable(accessor: (Map map) => map[variableNameHorizontal] as String),
              variableNameVertical: Variable(accessor: (Map map) => map[variableNameVertical] as num, scale: LinearScale(formatter: (v) => getNumberAsShorthandText(v))),
            },
            axes: [
              Defaults.horizontalAxis,
              Defaults.verticalAxis,
            ],
            selections: {
              'touchMove': PointSelection(
                on: {GestureType.scaleUpdate, GestureType.tapDown, GestureType.longPressMoveUpdate},
                dim: Dim.x,
              )
            },
            tooltip: TooltipGuide(
              followPointer: [false, true],
              align: Alignment.topLeft,
              offset: const Offset(-20, -20),
            ),
          )),
    );
  }
}
