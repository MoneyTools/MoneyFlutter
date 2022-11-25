import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../helpers.dart';

class CaptionAndCounter extends StatelessWidget {
  final String caption;
  final num count;
  final bool small;
  final bool vertical;

  const CaptionAndCounter({Key? key, this.caption = "", this.count = 0, this.small = false, this.vertical = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (vertical) {
      return Column(children: [renderCaption(context), renderCount(context)]);
    }

    return Row(children: [renderCaption(context), const SizedBox(width: 10), renderCount(context)]);
  }

  Widget renderCaption(context) {
    if (small) {
      return Text(caption, style: getTextTheme(context).button);
    } else {
      return Text(caption, style: getTextTheme(context).headline6);
    }
  }

  Widget renderCount(context) {
    final format = NumberFormat.decimalPattern().format(count);
    return Text(format, style: getTextTheme(context).caption);
  }
}
