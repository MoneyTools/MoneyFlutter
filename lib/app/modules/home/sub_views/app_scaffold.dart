import 'package:flutter/material.dart';
import 'package:money/app/controller/preferences_controller.dart';

Widget myScaffold(
  final BuildContext context,
  final PreferredSizeWidget? appBar,
  final Widget body,
) {
  final data = MediaQuery.of(context).copyWith(
    textScaler: TextScaler.linear(PreferenceController.to.textScale),
  );
  return MediaQuery(
      data: data,
      child: Scaffold(
        appBar: appBar,
        body: body,
      ));
}
