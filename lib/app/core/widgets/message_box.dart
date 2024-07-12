import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/gaps.dart';

/// Display a message to the user
void messageBox(
  final BuildContext context,
  final String message,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        children: [
          gapLarge(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(message),
          ),
          gapLarge(),
        ],
      );
    },
  );
}

class DialogService {
  factory DialogService() => _instance;

  DialogService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // singleton
  static final DialogService _instance = DialogService._internal();

  Future<void> showMessageBox(String title, String message) async {
    await showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SelectableText(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
