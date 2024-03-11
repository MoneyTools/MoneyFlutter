import 'package:flutter/material.dart';

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

class MyFullDialog extends StatelessWidget {
  final Widget child;

  const MyFullDialog({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      // Set elevation to 0 to remove default shadow
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
