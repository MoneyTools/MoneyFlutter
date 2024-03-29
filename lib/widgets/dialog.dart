import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/widgets/dialog_button.dart';
import 'package:money/widgets/dialog_full_screen.dart';

void myShowDialog({
  required final BuildContext context,
  required final String title,
  required final Widget child,
  required final List<Widget> actionButtons,
  final bool includeDoneButton = true,
}) {
  if (isSmallDevice(context)) {
    // Full screen also comes with a Close (X) button
    Navigator.of(context).push(
      MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return FullScreenDialog(
            title: title,
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: child,
            ),
          );
        },
        fullscreenDialog: true,
      ),
    );
  } else {
    // in modal always offer a close button
    if (includeDoneButton) {
      actionButtons.add(DialogActionButton(
          text: 'Done',
          onPressed: () {
            Navigator.of(context).pop(false);
          }));
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (final BuildContext context) {
          return AlertDialog(
            title: Text(title),
            scrollable: true,
            content: child,
            actions: actionButtons,
          );
        });
  }
}
