import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/rectangle.dart';

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
