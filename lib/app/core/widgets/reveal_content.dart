import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';

class RevealContent extends StatefulWidget {

  const RevealContent({
    super.key,
    required this.widgets,
    this.textForClipboard = '',
  });
  final List<Widget> widgets;
  final String textForClipboard;

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
    return InkWell(
      onTap: _toggleReveal,
      onLongPress: () {
        if (widget.textForClipboard.isNotEmpty) {
          copyToClipboardAndInformUser(context, widget.textForClipboard);
        }
      },
      child: widget.widgets[_showItem],
    );
  }
}
