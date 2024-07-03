// ignore_for_file: unnecessary_this
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';

class YearRangeSlider extends StatefulWidget {
  YearRangeSlider({
    super.key,
    required this.minYear,
    required this.maxYear,
    required this.onChanged,
  }) {
    spanInYears = maxYear - minYear;
  }
  final int minYear;
  final int maxYear;
  final void Function(int minYear, int maxYear) onChanged;
  late final int spanInYears;

  @override
  YearRangeSliderState createState() => YearRangeSliderState();
}

class YearRangeSliderState extends State<YearRangeSlider> {
  late int _selectedYearMin = widget.minYear;
  late int _selectedYearMax = widget.maxYear;

  // Bottom drag related properties
  final double sliderEdgePadding = 20;
  double _dragGesturePosition = 0;
  double _leftMarginOfBottomText = 0;
  double _dragBottomWidth = 0;

  int get _rangeSpanSelectedYears => _selectedYearMax - _selectedYearMin + 1;

  @override
  Widget build(BuildContext context) {
    if (widget.minYear == 0 || widget.maxYear == 0 || widget.spanInYears == 0) {
      return const Text('No date range yet');
    }

    return LayoutBuilder(
      builder: (BuildContext context, final BoxConstraints constraints) {
        final double visualWidthOfSlider = constraints.maxWidth - (sliderEdgePadding * 2);
        final double eachYearInPixel = visualWidthOfSlider / widget.spanInYears;

        _dragBottomWidth = max((_rangeSpanSelectedYears - 1) * eachYearInPixel, 162);

        final int spanFromStartingPosition = _selectedYearMin - widget.minYear;
        final double selectedYearPositionInPixel = spanFromStartingPosition * eachYearInPixel;
        _leftMarginOfBottomText = min(selectedYearPositionInPixel, visualWidthOfSlider - _dragBottomWidth);
        _leftMarginOfBottomText = max(0, _leftMarginOfBottomText);

        return SizedBox(
          height: 60,
          child: Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              RangeSlider(
                min: widget.minYear.toDouble(),
                max: widget.maxYear.toDouble(),
                values: RangeValues(_selectedYearMin.toDouble(), _selectedYearMax.toDouble()),
                labels: RangeLabels(_selectedYearMin.toString(), _selectedYearMax.toString()),
                divisions: widget.spanInYears,
                onChanged: (final RangeValues values) {
                  setState(() {
                    _selectedYearMin = values.start.toInt();
                    _selectedYearMax = values.end.toInt();
                    widget.onChanged(_selectedYearMin, _selectedYearMax);
                  });
                },
              ),
              GestureDetector(
                onHorizontalDragUpdate: (final DragUpdateDetails details) {
                  setState(() {
                    _dragGesturePosition += details.primaryDelta!;
                    final double thresholdForMovingToNextPosition = constraints.maxWidth / widget.spanInYears / 4;

                    if (_dragGesturePosition >= thresholdForMovingToNextPosition) {
                      _dragGesturePosition = 0;
                      if (_selectedYearMax + 1 <= widget.maxYear) {
                        _selectedYearMin++;
                        _selectedYearMax++;
                      }
                    } else if (_dragGesturePosition <= -thresholdForMovingToNextPosition) {
                      _dragGesturePosition = 0;
                      if (_selectedYearMin - 1 >= widget.minYear) {
                        _selectedYearMin--;
                        _selectedYearMax--;
                      }
                    }
                    widget.onChanged(_selectedYearMin, _selectedYearMax);
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

  Widget _buildDragButton(final BuildContext context) {
    final String spanAsText =
        getSingularPluralText(_rangeSpanSelectedYears.toString(), _rangeSpanSelectedYears, 'years', 'year');
    final bool canBeDragged = _selectedYearMin != widget.minYear || _selectedYearMax != widget.maxYear;
    final Color textColor = getColorTheme(context).primary;

    return Container(
      width: _dragBottomWidth,
      margin: EdgeInsets.only(left: _leftMarginOfBottomText),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _selectedYearMin.toString(),
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
            _selectedYearMax.toString(),
            style: TextStyle(fontSize: 12, color: textColor),
          ),
        ],
      ),
    );
  }
}
