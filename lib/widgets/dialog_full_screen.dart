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
