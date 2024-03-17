import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: widget.content,
    );
  }
}

class AutoSizeDialog extends StatelessWidget {
  final Widget child;

  const AutoSizeDialog({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
          isSmallDevice(context) ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
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
