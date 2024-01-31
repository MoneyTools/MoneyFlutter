import 'package:flutter/material.dart';

/// Show a dialog box with a question for the user to take aciton on
class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.question,
    required this.onConfirm,
    this.icon,
    this.message, // Optional
    this.content, // optional
  });

  final Icon? icon;
  final String title;
  final String question;
  final String? message;
  final Widget? content;
  final VoidCallback onConfirm;

  @override
  Widget build(final BuildContext context) {
    Widget subContent = content == null ? Text(message ?? '') : content!;

    return AlertDialog(
      icon: icon,
      title: Text(title),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(
            height: 16,
          ),
          subContent,
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
