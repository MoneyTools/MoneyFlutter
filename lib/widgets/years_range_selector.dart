// ignore_for_file: unnecessary_this

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';

class YearRangeSlider extends StatefulWidget {
  final int minYear;
  final int maxYear;
  final void Function(int minYear, int maxYear) onChanged;
  late final int spanInYears;

  YearRangeSlider({
    super.key,
    required this.minYear,
    required this.maxYear,
    required this.onChanged,
  }) {
    spanInYears = this.maxYear - this.minYear;
  }

  @override
  YearRangeSliderState createState() => YearRangeSliderState();
}

class YearRangeSliderState extends State<YearRangeSlider> {
  late int _minYear = widget.minYear;
  late int _maxYear = widget.maxYear;
  final double sliderEdgePadding = 20;
  double _dragButtonWidth = 150;
  double _dragButtonPosition = 0;
  double _dragGesturePosition = 0;
  int _spanSelectedYears = 0;

  @override
  Widget build(BuildContext context) {
    int fullSpread = widget.maxYear - widget.minYear;

    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        updateRange(constraints.maxWidth);

        return SizedBox(
          height: 60,
          child: Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              RangeSlider(
                min: widget.minYear.toDouble(),
                max: widget.maxYear.toDouble(),
                values: RangeValues(_minYear.toDouble(), _maxYear.toDouble()),
                labels: RangeLabels(_minYear.toString(), _maxYear.toString()),
                divisions: fullSpread,
                onChanged: (RangeValues values) {
                  setState(() {
                    _minYear = values.start.toInt();
                    _maxYear = values.end.toInt();
                  });
                },
              ),
              GestureDetector(
                onHorizontalDragUpdate: (DragUpdateDetails details) {
                  setState(() {
                    _dragGesturePosition += details.primaryDelta!;
                    double thresholdForMovingToNextPosition = constraints.maxWidth / (widget.maxYear - widget.minYear);
                    thresholdForMovingToNextPosition /= 4;

                    // Update min and max values
                    if (_dragGesturePosition >= thresholdForMovingToNextPosition) {
                      _dragGesturePosition = 0;
                      if (_maxYear + 1 <= widget.maxYear) {
                        _minYear++;
                        _maxYear++;
                      }
                    }
                    if (_dragGesturePosition <= -thresholdForMovingToNextPosition) {
                      _dragGesturePosition = 0;
                      if (_minYear - 1 >= widget.minYear) {
                        _minYear--;
                        _maxYear--;
                      }
                    }
                  });
                },
                child: _buildDragButton(),
              ),
            ],
          ),
        );
      },
    );
  }

  void updateRange(double horizontalMaxWidth) {
    // let the caller know that the values have changed
    widget.onChanged(_minYear, _maxYear);

    // Position the drag button using the left side position of the in year
    double eachYearInPixel = horizontalMaxWidth / widget.spanInYears;
    _spanSelectedYears = _maxYear - _minYear;
    double centerOfSpan = _minYear + _spanSelectedYears / 2;
    double offsetFromLeftInYear = centerOfSpan - widget.minYear;
    double selectedYearPositionInPixel = (offsetFromLeftInYear * eachYearInPixel);
    _dragButtonWidth = max((_spanSelectedYears * eachYearInPixel) - (sliderEdgePadding / 2), 150);

    _dragButtonPosition = selectedYearPositionInPixel - (_dragButtonWidth / 2);
    // clamp position
    // do not go beyond the right side
    _dragButtonPosition = min(_dragButtonPosition, horizontalMaxWidth - _dragButtonWidth - sliderEdgePadding);
    // left side starts after the space allocated for the left slider
    _dragButtonPosition = max(_dragButtonPosition, sliderEdgePadding);
  }

  Widget _buildDragButton() {
    String spanAsText = '$_spanSelectedYears ${_spanSelectedYears > 1 ? 'years' : 'year'}';

    return Container(
      width: _dragButtonWidth,
      height: 20,
      margin: EdgeInsets.only(left: _dragButtonPosition),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: getColorTheme(context).primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_minYear.toString(), style: TextStyle(fontSize: 12, color: getColorTheme(context).onPrimary)),
          Text(spanAsText, style: TextStyle(fontSize: 12, color: getColorTheme(context).onPrimary)),
          Text(_maxYear.toString(), style: TextStyle(fontSize: 12, color: getColorTheme(context).onPrimary)),
        ]),
      ),
    );
  }
}
