import 'package:flutter/material.dart';

class SnackBarService {
  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  static void showSnackBar({
    required String message,
    bool autoDismiss = true,
  }) {
    scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        showCloseIcon: !autoDismiss,
      ),
    );
  }
}
