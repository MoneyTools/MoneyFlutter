import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class MyCircle extends StatelessWidget {
  final Color colorFill;
  final Color colorBorder;
  final double size;
  final bool showBorder;

  const MyCircle({
    super.key,
    required this.colorFill,
    this.colorBorder = Colors.grey,
    required this.size,
    this.showBorder = false,
  });

  @override
  Widget build(final BuildContext context) {
    return DottedBorder(
      padding: EdgeInsets.zero,
      dashPattern: colorFill == Colors.transparent ? const <double>[4.0, 2.0] : const <double>[100.0, 0.0],
      color: colorBorder,
      borderType: BorderType.Circle,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colorFill,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
