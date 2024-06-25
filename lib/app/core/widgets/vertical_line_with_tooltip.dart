import 'dart:math';

import 'package:flutter/material.dart';

class VerticalLineWithTooltip extends StatelessWidget {

  const VerticalLineWithTooltip({
    super.key,
    required this.height,
    this.width = 5,
    required this.color,
    required this.tooltip,
  });
  final double height;
  final double width;
  final Color color;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: _build(),
    );
  }

  Widget _build() {
    if (height == 0) {
      // we do this just to get the tooltip to work
      return SizedBox(
        height: 5,
        width: width,
      );
    } else {
      return Container(
        height: max(1, height),
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }
  }
}
