import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/vertical_line_with_tooltip.dart';

class MiniTimelineTwelveMonths extends StatelessWidget {
  final List<Pair<int, double>> values;
  final Color color;

  const MiniTimelineTwelveMonths({super.key, required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (final BuildContext context, final BoxConstraints constraints) {
      List<Widget> bars = [];

      if (values.isNotEmpty) {
        num maxValue = 0;
        for (final p in values) {
          maxValue = max(maxValue, p.second.abs());
        }

        double ratio = constraints.maxHeight / maxValue;
        for (final value in values) {
          final double height = value.second.abs() * ratio;
          bars.add(
            VerticalLineWithTooltip(
              height: height,
              color: color,
              tooltip: '${value.first} X ${doubleToCurrency(value.second)}',
            ),
          );
        }
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
}
