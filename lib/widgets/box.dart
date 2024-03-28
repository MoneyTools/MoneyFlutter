import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? width;
  final double? height;

  const Box({
    super.key,
    this.color,
    this.width,
    this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(
        minWidth: 500,
        maxWidth: 500,
      ),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0), // Bor
        border: Border.all(
          width: 1,
          color: Colors.grey.withOpacity(0.5),
        ),
      ),
      child: child,
    );
  }
}
