import 'package:flutter/material.dart';

class ScrollBothWay extends StatelessWidget {
  final ScrollController _horizontal = ScrollController();
  final ScrollController _vertical = ScrollController();
  final Widget child;

  ScrollBothWay({
    super.key,
    required this.child,
  });

  @override
  Widget build(final BuildContext context) {
    return SizedBox(
      height: 2500,
      width: 2400,
      child: Scrollbar(
        controller: _vertical,
        thumbVisibility: true,
        trackVisibility: true,
        child: Scrollbar(
          controller: _horizontal,
          thumbVisibility: true,
          trackVisibility: true,
          notificationPredicate: (final ScrollNotification notification) => notification.depth == 1,
          child: SingleChildScrollView(
            controller: _vertical,
            child: SingleChildScrollView(
              controller: _horizontal,
              scrollDirection: Axis.horizontal,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
