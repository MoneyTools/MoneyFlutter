import 'package:flutter/material.dart';
import 'package:money/widgets/dialog/dialog.dart';
import 'package:money/widgets/dialog/dialog_button.dart';

void showDeleteConfirmationDialog(
  final BuildContext context,
  final String title,
  final String question,
  final Widget? content,
  final Function onConfirmationToDelete,
) {
  adaptiveScreenSizeDialog(
    context: context,
    title: title,
    captionForClose: 'Cancel',
    actionButtons: [
      DialogActionButton(
        text: 'Delete',
        onPressed: () {
          onConfirmationToDelete();
          Navigator.of(context).pop();
        },
      ),
    ], // this will hide the close button
    child: DeleteConfirmationDialog(
      question: question,
      content: content ?? const SizedBox(),
      onConfirm: () {},
    ),
  );
}

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(question, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        // Content or simple message
        Center(child: content ?? Text(message ?? '')),
        const Spacer(),
      ],
    );
  }
}
