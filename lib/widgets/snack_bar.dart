import 'package:flutter/material.dart';

class SnackBarService {
  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  static void showSnackBar({
    required String message,
    bool autoDismiss = true,
  }) {
    scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: SelectableText(message),
        duration: autoDismiss ? const Duration(milliseconds: 4000) : const Duration(minutes: 100),
        showCloseIcon: !autoDismiss,
      ),
    );
  }
}
