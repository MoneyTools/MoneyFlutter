import 'package:flutter/material.dart';
import 'package:money/widgets/gaps.dart';

/// Display a message to the user
void messageBox(
  final BuildContext context,
  final String message,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        children: [
          gapLarge(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(message),
          ),
          gapLarge(),
        ],
      );
    },
  );
}
