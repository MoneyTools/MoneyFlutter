import 'package:flutter/material.dart';

class DialogActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const DialogActionButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

Widget dialogActionButtons(final List<Widget> actionsButtons) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: actionsButtons,
  );
}
