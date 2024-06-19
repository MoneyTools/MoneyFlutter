import 'package:flutter/material.dart';
import 'package:money/widgets/dialog/dialog.dart';
import 'package:money/widgets/dialog/dialog_button.dart';
import 'package:money/widgets/gaps.dart';

void showConfirmationDialog({
  required final BuildContext context,
  required final String title,
  required final String buttonText,
  required final Function onConfirmation,
  String question = '',
  Widget? content,
}) {
  adaptiveScreenSizeDialog(
    context: context,
    title: title,
    captionForClose: 'Cancel',
    actionButtons: [
      DialogActionButton(
        text: buttonText,
        onPressed: () {
          onConfirmation();
          Navigator.of(context).pop();
        },
      ),
    ], // this will hide the close button
    child: ConfirmationDialog(
      question: question,
      content: content ?? const SizedBox(),
      onConfirm: () {},
    ),
  );
}

/// Show a dialog box with a question for the user to take action on
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.question,
    required this.onConfirm,
    this.content, // optional
  });

  final String question;
  final Widget? content; // or a widget
  final VoidCallback onConfirm;

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: IntrinsicHeight(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(question, style: Theme.of(context).textTheme.titleMedium),
            gapLarge(),
            // optional Content
            if (content != null)
              Expanded(
                child: content!,
              ),
          ],
        ),
      ),
    );
  }
}
