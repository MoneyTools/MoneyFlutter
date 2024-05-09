import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/money_model.dart';
import 'package:money/widgets/circle.dart';
import 'package:money/widgets/gaps.dart';
import 'package:money/widgets/money_widget.dart';

class Distribution {
  final String title;
  final Color color;
  final double amount;
  double percentage = 0;

  Distribution({
    required this.title,
    required this.amount,
    this.color = Colors.transparent,
  });
}

class DistributionBar extends StatelessWidget {
  final List<Distribution> segments;
  final List<Widget> segmentWidgets = [];
  final List<Widget> detailRowWidgets = [];

  DistributionBar({super.key, required this.segments});

  @override
  Widget build(BuildContext context) {
    double sum = segments.fold(0, (previousValue, element) => previousValue + element.amount.abs());
    if (sum > 0) {
      for (final segment in segments) {
        segment.percentage = segment.amount.abs() / sum;
      }
    }
    // Sort descending by percentage
    segments.sort((a, b) => b.percentage.compareTo(a.percentage));

    initWidgets(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHorizontalBar(),
        gapSmall(),
        _buildRowOfDetails(),
      ],
    );
  }

  void initWidgets(final BuildContext context) {
    for (final segment in segments) {
      Color backgroundColorOfSegment = segment.color;
      Color foregroundColorOfSegment = contrastColor(backgroundColorOfSegment);

      if (backgroundColorOfSegment.opacity == 0) {
        backgroundColorOfSegment = Colors.grey;
        foregroundColorOfSegment = Colors.white;
      }

      segmentWidgets.add(
        Expanded(
          // use the percentage to determine the relative width
          flex: (segment.percentage * 100).toInt().abs(),
          child: Tooltip(
            message: segment.title,
            child: Container(
              alignment: Alignment.center,
              color: backgroundColorOfSegment,
              margin: EdgeInsets.only(right: segment == segments.last ? 0.0 : 1.0),
              child: _builtSegmentOverlayText(segment.percentage, foregroundColorOfSegment),
            ),
          ),
        ),
      );

      detailRowWidgets.add(_buildDetailRow(
        context,
        segment.title,
        MyCircle(colorFill: segment.color, size: 16),
        segment.amount,
      ));
    }
  }

  Widget _buildHorizontalBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3), // Radius for rounded ends
      child: SizedBox(
        height: 20,
        child: Row(
          children: segmentWidgets,
        ),
      ),
    );
  }

  Widget _builtSegmentOverlayText(final double percentage, final Color color) {
    int value = (percentage * 100).toInt();
    if (value <= 0) {
      return const SizedBox();
    }
    return Text(
      '$value%',
      softWrap: false,
      overflow: TextOverflow.clip,
      style: TextStyle(color: color, fontSize: 9),
    );
  }

  Widget _buildRowOfDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: detailRowWidgets,
    );
  }

  Widget _buildDetailRow(
    final BuildContext context,
    final String label,
    final Widget colorWidget,
    final double value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        colorWidget,
        gapSmall(),
        Expanded(
            flex: 2,
            child: Text(
              label,
              style: getTextTheme(context).labelMedium,
              textAlign: TextAlign.justify,
              textWidthBasis: TextWidthBasis.longestLine,
              softWrap: false,
            )),
        Expanded(
            child: MoneyWidget(
          amountModel: MoneyModel(
            amount: value,
          ),
          asTile: false,
        )),
      ],
    );
  }
}
