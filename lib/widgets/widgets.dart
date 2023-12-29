import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

Widget renderIconAndText(final Widget icon, final String text) {
  return Padding(
    padding: const EdgeInsets.only(left: 10),
    child: Row(
      children: <Widget>[
        icon,
        Padding(padding: const EdgeInsets.only(left: 20), child: Text(text)),
      ],
    ),
  );
}

bool isMobile() {
  return defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android;
}
