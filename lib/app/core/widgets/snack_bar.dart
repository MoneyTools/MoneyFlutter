import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';

class SnackBarService {
  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  static void display({
    required String message,
    bool autoDismiss = true,
    Color? backgroundColor,
  }) {
    scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: SelectableText(message),
        duration: autoDismiss ? const Duration(milliseconds: 4000) : const Duration(minutes: 100),
        showCloseIcon: !autoDismiss,
      ),
    );
  }

  static void displaySuccess({
    required String message,
    bool autoDismiss = true,
  }) {
    return display(message: message, autoDismiss: autoDismiss, backgroundColor: getColorFromState(ColorState.success));
  }

  static void displayWarning({
    required String message,
    bool autoDismiss = true,
  }) {
    return display(message: message, autoDismiss: autoDismiss, backgroundColor: getColorFromState(ColorState.warning));
  }

  static void displayError({
    required String message,
    bool autoDismiss = true,
  }) {
    return display(message: message, autoDismiss: autoDismiss, backgroundColor: getColorFromState(ColorState.error));
  }
}
