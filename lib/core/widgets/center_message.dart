import 'package:flutter/material.dart';
import 'package:money/core/widgets/box.dart';
import 'package:money/data/models/constants.dart';

/// a basic text that is centered in the parent container
class CenterMessage extends StatelessWidget {
  /// constructor
  const CenterMessage({required this.message, this.child, super.key});

  factory CenterMessage.noItems() {
    return const CenterMessage(message: 'No items');
  }

  factory CenterMessage.noTransaction() {
    return const CenterMessage(message: 'No transactions.');
  }

  final Widget? child;
  final String message;

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: Box(
        width: 400,
        height: 60,
        child: Center(
          child: IntrinsicWidth(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(message),
                ),
                if (child != null)
                  Padding(
                    padding: const EdgeInsets.only(left: SizeForPadding.huge),
                    child: child!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
