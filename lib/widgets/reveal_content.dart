import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';

class RevealContent extends StatefulWidget {
  final List<Widget> widgets;
  final String textForClipboard;

  const RevealContent({
    super.key,
    required this.widgets,
    this.textForClipboard = '',
  });

  @override
  RevealContentState createState() => RevealContentState();
}

class RevealContentState extends State<RevealContent> {
  int _showItem = 0;

  void _toggleReveal() {
    setState(() {
      _showItem++;
      if (_showItem >= widget.widgets.length) {
        _showItem = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _toggleReveal,
      onLongPress: () {
        if (widget.textForClipboard.isNotEmpty) {
          copyToClipboardAndInformUser(context, widget.textForClipboard);
        }
      },
      child: widget.widgets[_showItem],
    );
  }
}
