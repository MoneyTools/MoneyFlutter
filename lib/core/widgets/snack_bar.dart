import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/core/helpers/color_helper.dart';

class SnackBarService {
  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  static void display({
    required String title,
    required String message,
    bool autoDismiss = true,
    Color backgroundColor = Colors.black,
    int duration = 5,
  }) {
    final Color textColor = contrastColor(backgroundColor);
    Get.snackbar(
      title, message,
      margin: const EdgeInsets.all(10),
      messageText: SelectableText(message, style: TextStyle(color: textColor)),
      isDismissible: true,
      snackPosition: SnackPosition.BOTTOM, // Position of the Snackbar
      snackStyle: SnackStyle.FLOATING,
      backgroundColor: backgroundColor, // Background color of the Snackbar
      colorText: textColor, // Text color of the Snackbar
      duration: autoDismiss ? Duration(seconds: duration) : null, // Duration for which the Snackbar is displayed
      mainButton: TextButton(
        key: const Key('key_snackbar_close_button'),
        onPressed: () {
          // Dismiss the Snackbar when the close button is pressed
          if (Get.isSnackbarOpen) {
            Get.back<dynamic>();
          }
        },
        child: Icon(Icons.close, color: textColor),
      ),
    );
  }

  static void displayError({
    required String message,
    String title = 'Error',
    bool autoDismiss = true,
  }) {
    return display(
      title: title,
      message: message,
      autoDismiss: autoDismiss,
      backgroundColor: getColorFromState(ColorState.error),
    );
  }

  static void displaySuccess({
    required String message,
    String title = 'OK',
    bool autoDismiss = true,
  }) {
    return display(
      title: title,
      message: message,
      autoDismiss: autoDismiss,
      backgroundColor: getColorFromState(ColorState.success),
    );
  }

  static void displayWarning({
    required String message,
    String title = 'Warning',
    bool autoDismiss = true,
  }) {
    return display(
      title: title,
      message: message,
      autoDismiss: autoDismiss,
      backgroundColor: getColorFromState(ColorState.warning),
    );
  }
}
