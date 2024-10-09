import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:money/core/widgets/gaps.dart';
import 'package:money/core/widgets/my_text_input.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showTextInputDialog({
  required BuildContext context,
  required Function(String) onContinue,
  final String title = 'Input',
  final String subTitle = '',
  final String initialValue = '',
  Function? onCancel,
}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController textEditingController = TextEditingController();
      textEditingController.text = initialValue;
      return AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 400,
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Markdown(
                  data: subTitle,
                  selectable: true,
                  onTapLink: (String text, String? href, String title) {
                    launchUrl(Uri.parse(href!));
                  },
                ),
              ),
              gapLarge(),
              Expanded(
                child: MyTextInput(
                  controller: textEditingController,
                  hintText: 'Enter $title',
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onCancel?.call();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              String text = textEditingController.text;
              Navigator.pop(context);
              onContinue(text);
            },
            child: const Text('Continue'),
          ),
        ],
      );
    },
  );
}
