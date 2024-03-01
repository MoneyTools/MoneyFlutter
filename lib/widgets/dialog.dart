import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/widgets/dialog_button.dart';
import 'package:money/widgets/dialog_full_screen.dart';

void myShowDialog({
  required final BuildContext context,
  required final String title,
  required final Widget child,
  required final List<Widget> actionButtons,
  final bool includeCloseButton = true,
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
    if (includeCloseButton) {
      actionButtons.add(DialogActionButton(
          text: 'Close',
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
            content: child,
            actions: actionButtons,
          );
        });
  }
}

List<Widget> buildActionButtons(
  final BuildContext context,
  final bool isEditable,
  final Function? onActionDelete,
) {
  if (isEditable) {
    return <Widget>[
      if (onActionDelete != null)
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onActionDelete.call();
          },
          child: const Text('Delete'),
        ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(false);
        },
        child: const Text('Discard'),
      ),
      DialogActionButton(
        text: 'Apply',
        onPressed: () {
          Navigator.of(context).pop(true);
        },
      ),
    ];
  }

  // Just the close button
  return <Widget>[
    DialogActionButton(
      text: 'Done',
      onPressed: () {
        Navigator.of(context).pop(true);
      },
    ),
  ];
}
