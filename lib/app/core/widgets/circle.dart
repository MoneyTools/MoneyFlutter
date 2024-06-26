import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/rectangle.dart';

class MyCircle extends StatelessWidget {
  const MyCircle({
    required this.colorFill,
    required this.size,
    super.key,
    this.colorBorder = Colors.grey,
    this.showBorder = false,
  });
  final Color colorFill;
  final Color colorBorder;
  final double size;
  final bool showBorder;

  @override
  Widget build(final BuildContext context) {
    return MyRectangle(
      key: key,
      shape: BoxShape.circle,
      colorFill: colorFill,
      colorBorder: colorBorder,
      size: size,
      showBorder: showBorder,
    );
  }
}
