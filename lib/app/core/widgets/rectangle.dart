import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class MyRectangle extends StatelessWidget {
  final Color colorFill;
  final Color colorBorder;
  final double size;
  final double borderSize;
  final bool showBorder;
  final BoxShape shape;

  const MyRectangle({
    super.key,
    required this.size,
    required this.colorFill,
    this.colorBorder = Colors.grey,
    this.shape = BoxShape.rectangle,
    this.showBorder = false,
    this.borderSize = 2,
  });

  @override
  Widget build(final BuildContext context) {
    return DottedBorder(
      padding: EdgeInsets.zero,
      dashPattern: colorFill == Colors.transparent ? const <double>[4.0, 2.0] : const <double>[100.0, 0.0],
      color: colorBorder,
      strokeWidth: borderSize,
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
