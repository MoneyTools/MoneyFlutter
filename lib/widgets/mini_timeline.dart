import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/helpers/string_helper.dart';

class HorizontalTimelineGraph extends StatelessWidget {
  final List<double> values;
  final Color color;

  const HorizontalTimelineGraph({super.key, required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (final BuildContext context, final BoxConstraints constraints) {
      List<Widget> bars = [];

      final num maxValue = values.reduce(max);
      double ratio = constraints.maxHeight / maxValue;
      for (final value in values) {
        final double height = value * ratio;
        bars.add(
          Tooltip(
            message: getAmountAsShorthandText(value),
            child: _buildVerticalBar(height),
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars,
            ),
          ),
          const Divider(
            height: 2,
            thickness: 2,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMontLabel('J'),
              _buildMontLabel('F'),
              _buildMontLabel('M'),
              _buildMontLabel('A'),
              _buildMontLabel('M'),
              _buildMontLabel('J'),
              _buildMontLabel('J'),
              _buildMontLabel('A'),
              _buildMontLabel('S'),
              _buildMontLabel('O'),
              _buildMontLabel('N'),
              _buildMontLabel('D'),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildMontLabel(final String text) {
    return Text(text, style: const TextStyle(fontSize: 8));
  }

  Widget _buildVerticalBar(double height) {
    if (height == 0) {
      // we do this just to get the tooltip to work
      return const SizedBox(
        height: 5,
        width: 5,
      );
    } else {
      return Container(
        height: height,
        width: 5,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }
  }
}
