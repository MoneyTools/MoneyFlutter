import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/modules/home/sub_views/app_scaffold.dart';

///
class FullScreenDialog extends StatefulWidget {
  final String title;
  final Widget content;

  const FullScreenDialog({super.key, required this.title, required this.content});

  @override
  FullScreenDialogState createState() => FullScreenDialogState();
}

class FullScreenDialogState extends State<FullScreenDialog> {
  @override
  Widget build(BuildContext context) {
    return myScaffold(
      context,
      AppBar(
        title: Text(widget.title),
      ),
      widget.content,
    );
  }
}

class AutoSizeDialog extends StatelessWidget {
  final Widget child;

  const AutoSizeDialog({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    ShapeBorder? dialogShape;
    EdgeInsets? insetPadding;

    if (isSmallDevice(context)) {
      insetPadding = EdgeInsets.zero;
    } else {
      dialogShape = RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        side: BorderSide(
          width: 2.0, // Adjust border width as needed
          color: Theme.of(context).dividerColor, // Set your desired border color here
        ),
      );
      insetPadding = const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0);
    }

    return Dialog(
      shape: dialogShape,
      insetPadding: insetPadding,
      // Set elevation to 0 to remove default shadow
      elevation: 0.0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}
