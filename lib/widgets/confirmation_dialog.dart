import 'package:flutter/material.dart';

/// Show a dialog box with a question for the user to take action on
class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.question,
    required this.onConfirm,
    this.message, // Optional
    this.content, // optional
  });

  final String title;
  final String question;
  final String? message; // either a message
  final Widget? content; // or a widget
  final VoidCallback onConfirm;

  @override
  Widget build(final BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        icon: const Icon(Icons.delete),
        title: Text(title),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(
              height: 16,
            ),
            // Content or simple message
            content ?? Text(message ?? ''),
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
      ),
    );
  }
}
