import 'dart:math';

import 'package:flutter/material.dart';

class MyBanner extends StatelessWidget {

  const MyBanner({
    super.key,
    required this.child,
    required this.on,
  });
  final Widget child;
  final bool on;

  @override
  Widget build(BuildContext context) {
    // final Color strikethroughColor = getColorFromState(ColorState.warning);
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: on ? 0.3 : 1, child: child),
        if (on)
          Transform.rotate(
            angle: -5 * pi / 180, // Convert degrees to radians
            child: Container(
              color: Colors.grey,
              child: const Text(' Skipping Duplicate ', style: TextStyle(color: Colors.black, fontSize: 10)),
            ),
          ),
      ],
    );
  }
}
