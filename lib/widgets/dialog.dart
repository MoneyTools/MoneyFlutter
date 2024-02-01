import 'package:flutter/material.dart';

void myShowDialog({
  required final BuildContext context,
  required final String title,
  required final Widget child,
  final bool isEditable = false,
}) {
  showDialog(
      context: context,
      builder: (final BuildContext context) {
        return Material(
          child: AlertDialog(
              title: Text(title),
              content: SizedBox(width: 400, height: 400, child: child),
              actions: actionButtons(context, isEditable)),
        );
      });
}

List<Widget> actionButtons(
  final BuildContext context,
  final bool isEditable,
) {
  if (isEditable) {
    return <Widget>[
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
