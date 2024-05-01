import 'package:flutter/material.dart';

class YearRangeSlider extends StatefulWidget {
  final int minYear;
  final int maxYear;
  final void Function(int minYear, int maxYear) onChanged;

  const YearRangeSlider({
    super.key,
    required this.minYear,
    required this.maxYear,
    required this.onChanged,
  });

  @override
  YearRangeSliderState createState() => YearRangeSliderState();
}

class YearRangeSliderState extends State<YearRangeSlider> {
  double _minValue = 0;
  double _maxValue = 100;

  late int _minYear = widget.minYear;
  late int _maxYear = widget.maxYear;

  @override
  Widget build(BuildContext context) {
    int fullSpread = widget.maxYear - widget.minYear;
    int selectedSpread = (_maxYear - _minYear) + 1;
    String spreadAsText = '$selectedSpread ${selectedSpread > 1 ? 'years' : 'year'}';

    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${widget.minYear}'),
            Expanded(
              child: RangeSlider(
                min: 0,
                max: 100,
                values: RangeValues(_minValue, _maxValue),
                labels: RangeLabels(_minYear.toString(), _maxYear.toString()),
                divisions: fullSpread,
                onChanged: (RangeValues values) {
                  setState(() {
                    _minValue = values.start;
                    _maxValue = values.end;
                    _minYear = (widget.minYear + ((_minValue / 100) * (widget.maxYear - widget.minYear))).round();
                    _maxYear = (widget.minYear + ((_maxValue / 100) * (widget.maxYear - widget.minYear))).round();

                    // let the caller know that the values have changed
                    widget.onChanged(_minYear, _maxYear);
                  });
                },
              ),
            ),
            Text('${widget.maxYear}'),
          ],
        ),
        Text(spreadAsText),
      ],
    );
  }
}
