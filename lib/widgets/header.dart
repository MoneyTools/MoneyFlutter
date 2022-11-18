import 'package:flutter/material.dart';
import 'package:money/helpers.dart';

class Header extends StatelessWidget {
  final String title;
  final num count;
  final String description;

  const Header(this.title, this.count, this.description, {super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (isSmallWidth(constraints)) {
          return _buildNarrow(context);
        } else {
          return _buildWide(context);
        }
      },
    );
  }

  _buildWide(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Row(children: [
          renderCaptionAndCount(context, title, count),
          const Spacer(),
          Text(description, style: getTextTheme(context).caption)
        ]));
  }

  _buildNarrow(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Column(
          children: [renderCaptionAndCount(context, title, count)],
        ));
  }

  renderCaptionAndCount(BuildContext context, String caption, num count) {
    return Row(children: [
      Text(caption, style: getTextTheme(context).headline6),
      const SizedBox(width: 10),
      Text('(${count.toString()})', style: getTextTheme(context).caption)
    ]);
  }
}
