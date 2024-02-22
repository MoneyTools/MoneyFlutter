import 'package:flutter/widgets.dart';

Widget gap(final double size) {
  return SizedBox(
    width: size,
    height: size,
  );
}

Widget gapSmall() {
  return gap(4);
}

Widget gapMedium() {
  return gap(8);
}

Widget gapLarge() {
  return gap(16);
}
