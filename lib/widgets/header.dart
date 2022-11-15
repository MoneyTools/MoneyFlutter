import 'package:flutter/material.dart';
import 'package:money/helpers.dart';

class Header extends StatefulWidget {
  final String title;
  final num count;
  final String description;

  const Header(this.title, this.count, this.description, {super.key});

  @override
  HeaderState createState() => HeaderState();
}

class HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (isSmallWidth(constraints)) {
          return _buildNarrow();
        } else {
          return _buildWide();
        }
      },
    );
  }

  _buildWide() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Expanded(
            child: Row(children: [
          renderCaptionAndCount(widget.title, widget.count),
          const Spacer(),
          Text(widget.description, style: Theme.of(context).textTheme.caption)
        ])));
  }

  _buildNarrow() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Expanded(
            child: Column(
          children: [renderCaptionAndCount(widget.title, widget.count)],
        )));
  }

  renderCaptionAndCount(caption, count) {
    return Row(children: [
      Text(widget.title, style: Theme.of(context).textTheme.headline6),
      const SizedBox(width: 10),
      Text('(${widget.count})', style: Theme.of(context).textTheme.caption)
    ]);
  }
}
