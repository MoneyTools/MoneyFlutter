import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class MyRectangle extends StatelessWidget {
  final Color colorFill;
  final Color colorBorder;
  final double size;
  final bool showBorder;
  final BoxShape shape;

  const MyRectangle({
    super.key,
    required this.colorFill,
    this.colorBorder = Colors.grey,
    required this.size,
    this.showBorder = false,
    this.shape = BoxShape.rectangle,
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
          shape: shape,
        ),
      ),
    );
  }
}
