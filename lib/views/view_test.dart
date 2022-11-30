import 'package:flutter/material.dart';

import '../widgets/header.dart';
import '../widgets/sankeyBand.dart';

class ViewTest extends StatefulWidget {
  const ViewTest({super.key});

  @override
  State<ViewTest> createState() => ViewTestState();
}

class ViewTestState extends State<ViewTest> {
  ViewTestState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Block> lefts = [
      Block("Left1", const Rect.fromLTWH(10, 10, 50, 100), Colors.blue, Colors.yellow),
      Block("Left2", const Rect.fromLTWH(10, 210, 50, 80), Colors.blue, Colors.yellow),
    ];
    Block right = Block("Right", const Rect.fromLTWH(400, 10, 25, 50), Colors.orange, Colors.yellow);

    return Expanded(
        child: ListView(children: [
      const Header("Test", 0, "Testing."),
      SizedBox(
        width: 1000,
        height: 1000,
        child: CustomPaint(
          painter: SankeyBandPaint(lefts, right),
        ),
      ),
    ]));
  }
}
