import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';

class DistributionBar extends StatelessWidget {
  final List<Color> colors;
  final List<double> percentages; // from 0.00 to 1.00

  const DistributionBar({super.key, required this.colors, required this.percentages});

  @override
  Widget build(BuildContext context) {
    assert(colors.length == percentages.length, 'Colors and percentages must have the same length.');

    return ClipRRect(
      borderRadius: BorderRadius.circular(3), // Radius for rounded ends
      child: SizedBox(
        height: 20,
        child: Row(
          children: _buildSegments(),
        ),
      ),
    );
  }

  List<Widget> _buildSegments() {
    List<Widget> segments = [];

    for (int i = 0; i < colors.length; i++) {
      Color backgroundColorOfSegment = colors[i];
      Color foregroundColorOfSegment = contrastColor(backgroundColorOfSegment);

      if (backgroundColorOfSegment.opacity == 0) {
        backgroundColorOfSegment = Colors.grey;
        foregroundColorOfSegment = Colors.white;
      }

      segments.add(
        Expanded(
          flex: (percentages[i] * 100).toInt(), // Percentage of total
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColorOfSegment, // Color of segment
              border: Border(
                right: BorderSide(
                  color: Colors.black, // Border color
                  width: i < segments.length - 1 ? 3.0 : 0.0, // Width of border (last segment has no border)
                ),
              ),
            ),
            child: _builtText(percentages[i], foregroundColorOfSegment),
          ),
        ),
      );
    }

    return segments;
  }

  Widget _builtText(final double percentage, final Color color) {
    int value = (percentage * 100).toInt();
    if (value <= 0) {
      return const SizedBox();
    }
    return Text(
      '$value%',
      style: TextStyle(color: color, fontSize: 9),
    );
  }
}
