import 'package:flutter/material.dart';

class MyIconButton extends StatefulWidget {
  const MyIconButton({
    super.key,
    required this.icon,
    required this.hoverColor,
    required this.tooltip,
    required this.onPressed,
  });

  final Color hoverColor;
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  MyIconButtonState createState() => MyIconButtonState();
}

class MyIconButtonState extends State<MyIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          size: 18,
          widget.icon,
          color: _isHovered ? widget.hoverColor : null,
        ),
        onPressed: widget.onPressed,
      ),
    );
  }
}
