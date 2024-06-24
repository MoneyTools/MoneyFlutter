import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/core/helpers/color_helper.dart';

class SnackBarService {
  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  static void display({
    required String title,
    required String message,
    bool autoDismiss = true,
    Color backgroundColor = Colors.black,
  }) {
    Color textColor = contrastColor(backgroundColor);
    Get.snackbar(
      title, message,
      messageText: SelectableText(message, style: TextStyle(color: textColor)),
      isDismissible: true,
      snackPosition: SnackPosition.BOTTOM, // Position of the Snackbar
      backgroundColor: backgroundColor, // Background color of the Snackbar
      colorText: textColor, // Text color of the Snackbar
      duration: autoDismiss ? const Duration(seconds: 5) : null, // Duration for which the Snackbar is displayed
      mainButton: TextButton(
        onPressed: () {
          // Dismiss the Snackbar when the close button is pressed
          if (Get.isSnackbarOpen) {
            Get.back();
          }
        },
        child: Icon(Icons.close, color: textColor),
      ),
    );
  }

  static void displaySuccess({
    required String message,
    bool autoDismiss = true,
  }) {
    return display(
        title: 'OK',
        message: message,
        autoDismiss: autoDismiss,
        backgroundColor: getColorFromState(ColorState.success));
  }

  static void displayWarning({
    required String message,
    bool autoDismiss = true,
  }) {
    return display(
        title: 'Warning',
        message: message,
        autoDismiss: autoDismiss,
        backgroundColor: getColorFromState(ColorState.warning));
  }

  static void displayError({
    required String message,
    bool autoDismiss = true,
  }) {
    return display(
        title: 'Error',
        message: message,
        autoDismiss: autoDismiss,
        backgroundColor: getColorFromState(ColorState.error));
  }
}
