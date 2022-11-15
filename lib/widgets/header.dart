import 'package:flutter/material.dart';

class Header extends StatefulWidget {
  final String title;
  final num count;
  final String description;

  const Header(this.title, this.count, this.description, {super.key});

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Expanded(
          child: Row(
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.headline6),
          const SizedBox(width: 10),
          Text('(${widget.count})', style: Theme.of(context).textTheme.caption),
          const Spacer(),
          Text(widget.description, style: Theme.of(context).textTheme.caption),
          const Text(""),
        ],
      )),
    );
  }
}
