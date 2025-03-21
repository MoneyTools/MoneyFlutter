import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/helpers/string_helper.dart';
import 'package:money/core/widgets/vertical_line_with_tooltip.dart';

class MiniTimelineTwelveMonths extends StatelessWidget {
  const MiniTimelineTwelveMonths({
    required this.values,
    required this.color,
    super.key,
  });

  final Color color;
  final List<Pair<int, double>> values;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        final List<Widget> bars = <Widget>[];

        if (values.isNotEmpty) {
          num maxValue = 0;
          for (final Pair<int, double> p in values) {
            maxValue = max(maxValue, p.second.abs());
          }

          final double ratio = constraints.maxHeight / maxValue;
          for (final Pair<int, double> value in values) {
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
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: bars,
              ),
            ),
            const Divider(height: 2, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
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
      },
    );
  }

  Widget _buildMontLabel(final String text) {
    return Text(text, style: const TextStyle(fontSize: 8));
  }
}
