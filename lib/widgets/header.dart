import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/widgets/caption_and_counter.dart';

class Header extends StatelessWidget {
  final String title;
  final num count;
  final String description;

  const Header(this.title, this.count, this.description, {super.key});

  @override
  Widget build(final BuildContext context) {
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        if (isSmallWidth(constraints)) {
          return _buildNarrow(context);
        } else {
          return _buildWide(context);
        }
      },
    );
  }

  Widget _buildWide(final BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Row(children: <Widget>[
          CaptionAndCounter(caption: title, value: count),
          const Spacer(),
          Text(description, style: getTextTheme(context).bodySmall)
        ]));
  }

  Widget _buildNarrow(final BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Column(
          children: <Widget>[CaptionAndCounter(caption: title, value: count)],
        ));
  }
}
