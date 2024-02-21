import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/widgets/dialog_full_screen.dart';

void myShowDialog({
  required final BuildContext context,
  required final String title,
  required final Widget child,
  final bool isEditable = false,
  final Function? onActionDelete,
}) {
  if (isSmallDevice(context)) {
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
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (final BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: child,
            actions: actionButtons(context, isEditable, onActionDelete),
          );
        });
  }
}

List<Widget> actionButtons(
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
      const Spacer(),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(false);
        },
        child: const Text('Discard'),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(true);
        },
        child: const Text('Apply'),
      ),
    ];
  }

  // Just the close button
  return <Widget>[
    TextButton(
      onPressed: () {
        Navigator.of(context).pop(true);
      },
      child: const Text('Done'),
    ),
  ];
}
