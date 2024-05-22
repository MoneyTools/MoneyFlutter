import 'package:flutter/material.dart';
import 'package:money/widgets/dialog/dialog_button.dart';

/// Show a dialog box with a question for the user to take action on
class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({
    super.key,
    required this.question,
    required this.onConfirm,
    this.message, // Optional
    this.content, // optional
  });

  final String question;
  final String? message; // either a message
  final Widget? content; // or a widget
  final VoidCallback onConfirm;

  @override
  Widget build(final BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: Theme.of(context).textTheme.titleMedium),

        const Spacer(),
        // Content or simple message
        Center(child: content ?? Text(message ?? '')),
        const Spacer(),

        dialogActionButtons(
          [
            DialogActionButton(
              text: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
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
      ],
    );
  }
}
