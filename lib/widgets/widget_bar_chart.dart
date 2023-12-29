import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import 'package:money/helpers.dart';

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
  Widget build(final BuildContext context) {
    final List<Map<String, Object>> data = <Map<String, Object>>[
      <String, Object>{variableNameHorizontal: '', variableNameVertical: 0},
      // TODO this is a hack, still don't know why I can just initialize directly
    ];
    data.clear(); // TODO part of the hack

    for (final CategoryValue entry in list) {
      data.add(<String, Object>{
        variableNameHorizontal: entry.category,
        variableNameVertical: entry.value
      });
    }

    if (data.isEmpty) {
      return Text('No chart to display ${list.length}');
    }

    const double w = 800.0;
    const double h = 300.0;

    return Center(
      child: SizedBox(
          width: w,
          height: h,
          child: Chart(
            data: data,
            marks: <Mark<Shape>>[IntervalMark()],
            variables: <String, Variable<Map, dynamic>>{
              variableNameHorizontal: Variable(
                  accessor: (final Map map) =>
                      map[variableNameHorizontal] as String),
              variableNameVertical: Variable(
                  accessor: (final Map map) => map[variableNameVertical] as num,
                  scale: LinearScale(
                      formatter: (final num v) => getNumberAsShorthandText(v))),
            },
            axes: <AxisGuide>[
              Defaults.horizontalAxis,
              Defaults.verticalAxis,
            ],
            selections: <String, Selection>{
              'touchMove': PointSelection(
                on: <GestureType>{
                  GestureType.scaleUpdate,
                  GestureType.tapDown,
                  GestureType.longPressMoveUpdate
                },
                dim: Dim.x,
              )
            },
            tooltip: TooltipGuide(
              followPointer: <bool>[false, true],
              align: Alignment.topLeft,
              offset: const Offset(-20, -20),
            ),
          )),
    );
  }
}
