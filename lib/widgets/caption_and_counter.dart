import 'package:flutter/material.dart';
import '../helpers.dart';

class CaptionAndCounter extends StatelessWidget {
  final String caption;
  final num value;
  final bool small;
  final bool vertical;

  const CaptionAndCounter({Key? key, this.caption = "", this.value = 0, this.small = false, this.vertical = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (vertical) {
      return Column(children: [renderCaption(context), renderValue(context)]);
    }

    return Row(children: [renderCaption(context), const SizedBox(width: 10), renderValue(context)]);
  }

  Widget renderCaption(context) {
    if (small) {
      return Text(caption, style: getTextTheme(context).button);
    } else {
      return Text(caption, style: getTextTheme(context).headline6);
    }
  }

  Widget renderValue(context) {
    if (value is int) {
      return Text(getIntAsText(value as int), style: getTextTheme(context).caption);
    }
    return Text(getCurrencyText(value as double), style: getTextTheme(context).caption);
  }
}
