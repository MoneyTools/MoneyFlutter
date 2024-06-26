import 'package:flutter/material.dart';

Future<void> showTextInputDialog({
  required BuildContext context,
  required Function(String) onContinue,
  final String title = 'Input',
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
          width: 300,
          child: TextField(
            controller: textEditingController,
            decoration: InputDecoration(hintText: 'Enter $title'),
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
