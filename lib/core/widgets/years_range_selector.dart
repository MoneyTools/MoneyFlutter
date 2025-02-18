// ignore_for_file: unnecessary_this
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/core/helpers/string_helper.dart';

/// A widget that allows users to select a range of years using a slider.
class YearRangeSlider extends StatefulWidget {
  /// Creates a [YearRangeSlider].
  ///
  /// [initialRange] specifies the initial range of years.
  /// [yearRange] specifies the range of years the slider can select.
  /// [onChanged] is a callback that returns the selected range of years whenever it changes.
  const YearRangeSlider({
    super.key,
    required this.initialRange,
    required this.yearRange,
    required this.onChanged,
  });

  /// The initial range of years.
  final NumRange initialRange;

  /// A callback that returns the selected range of years whenever it changes.
  final void Function(NumRange range) onChanged;

  /// The full range of years.
  final NumRange yearRange;

  @override
  YearRangeSliderState createState() => YearRangeSliderState();
}

class YearRangeSliderState extends State<YearRangeSlider> {
  // Bottom drag related properties
  final double sliderEdgePadding = 20;

  double _dragBottomWidth = 0;
  double _dragGesturePosition = 0;
  double _leftMarginOfBottomText = 0;

  /// The currently selected year range.
  late final NumRange _selectedYearRange = NumRange(min: widget.initialRange.min, max: widget.initialRange.max);

  @override
  Widget build(BuildContext context) {
    // If the year range is invalid, display a message.
    if (!widget.yearRange.isValid()) {
      return const Text('No date range yet');
    }

    return LayoutBuilder(
      builder: (BuildContext context, final BoxConstraints constraints) {
        final double visualWidthOfSlider = constraints.maxWidth - (sliderEdgePadding * 2);
        final double eachYearInPixel = visualWidthOfSlider / widget.yearRange.span;

        _updateDragBottomWidth(eachYearInPixel);
        _updateLeftMarginOfBottomText(visualWidthOfSlider, eachYearInPixel);

        return SizedBox(
          height: 58,
          child: Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: <Widget>[
              RangeSlider(
                min: widget.yearRange.min.toDouble(),
                max: widget.yearRange.max.toDouble(),
                values: RangeValues(_selectedYearRange.min.toDouble(), _selectedYearRange.max.toDouble()),
                labels: RangeLabels(_selectedYearRange.min.toString(), _selectedYearRange.max.toString()),
                divisions: widget.yearRange.span.toInt(),
                onChanged: (final RangeValues values) {
                  setState(() {
                    _selectedYearRange.update(values.start.round(), values.end.round());
                    widget.onChanged(_selectedYearRange);
                  });
                },
              ),
              GestureDetector(
                onHorizontalDragUpdate: (final DragUpdateDetails details) {
                  setState(() {
                    _handleDragUpdate(details, constraints.maxWidth);
                    widget.onChanged(_selectedYearRange);
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sliderEdgePadding),
                  child: _buildDragButton(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the drag button that displays the selected year range and allows dragging.
  ///
  /// [context] is the build context used to retrieve theme information.
  Widget _buildDragButton(final BuildContext context) {
    final String spanAsText =
        getSingularPluralText(_selectedYearRange.span.toString(), _selectedYearRange.span.toInt(), 'years', 'year');
    final bool canBeDragged =
        _selectedYearRange.min != widget.yearRange.min || _selectedYearRange.max != widget.yearRange.max;
    final Color textColor = getColorTheme(context).primary;

    return Container(
      width: _dragBottomWidth,
      margin: EdgeInsets.only(left: _leftMarginOfBottomText),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            _selectedYearRange.min.toString(),
            style: TextStyle(fontSize: 12, color: textColor),
          ),
          Opacity(
            opacity: canBeDragged ? 0.5 : 0,
            child: Icon(Icons.drag_indicator_outlined, color: textColor),
          ),
          Text(
            spanAsText,
            style: TextStyle(fontSize: 12, color: textColor),
          ),
          Opacity(
            opacity: canBeDragged ? 0.5 : 0,
            child: Icon(Icons.drag_indicator_outlined, color: textColor),
          ),
          Text(
            _selectedYearRange.max.toString(),
            style: TextStyle(fontSize: 12, color: textColor),
          ),
        ],
      ),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details, double maxWidth) {
    _dragGesturePosition += details.primaryDelta!;
    final double thresholdForMovingToNextPosition = maxWidth / widget.yearRange.span / 4;

    if (_dragGesturePosition >= thresholdForMovingToNextPosition) {
      _dragGesturePosition = 0;
      _selectedYearRange.increment(widget.yearRange.max.toInt());
    } else if (_dragGesturePosition <= -thresholdForMovingToNextPosition) {
      _dragGesturePosition = 0;
      _selectedYearRange.decrement(widget.yearRange.min.toInt());
    }
  }

  void _updateDragBottomWidth(double eachYearInPixel) {
    const double minimumWidthToFitAllElements = 162.0;
    _dragBottomWidth = max(_selectedYearRange.span * eachYearInPixel, minimumWidthToFitAllElements);
  }

  void _updateLeftMarginOfBottomText(double visualWidthOfSlider, double eachYearInPixel) {
    final double selectedYearPositionInPixel = (_selectedYearRange.min - widget.yearRange.min) * eachYearInPixel;
    _leftMarginOfBottomText = min(selectedYearPositionInPixel, visualWidthOfSlider - _dragBottomWidth);
    _leftMarginOfBottomText = max(0, _leftMarginOfBottomText);
  }
}
