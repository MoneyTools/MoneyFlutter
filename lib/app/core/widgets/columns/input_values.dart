import 'dart:io' as io;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:money/app/controller/theme_controler.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/box.dart';
import 'package:money/app/core/widgets/columns/columns_input.dart';
import 'package:money/app/core/widgets/ocr/ocr.dart';
import 'package:money/app/data/models/constants.dart';

class InputValues extends StatelessWidget {
  const InputValues({super.key, required this.controller, required this.title});
  final TextEditingController controller;
  final String title;

  @override
  Widget build(BuildContext context) {
    final int lineCount = getLineCount(controller.text);

    return Stack(
      fit: StackFit.expand,
      children: [
        Box(
          height: 200,
          width: 800,
          header: buildHeaderTitleAndCounter(context, title, lineCount, 'lines'),
          child: TextField(
            controller: controller,
            // focusNode: focusNode,
            autofocus: false,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontSize: SizeForText.small,
              overflow: TextOverflow.fade,
            ),
            // decoration: getDecoration(context, title, lineCount),
            inputFormatters: [
              TextInputFormatterRemoveEmptyLines(), // remove empty line
            ],
          ),
        ),
        if (!kIsWeb && !io.Platform.isWindows)
          Align(
            alignment: Alignment.bottomCenter,
            child: PasteOcr(textController: controller),
          ),
      ],
    );
  }
}

InputDecoration getDecoration(
  final BuildContext context,
  final String title,
  final int lineCount,
) {
  return InputDecoration(
    label: Badge(
      isLabelVisible: lineCount > 0,
      backgroundColor: ThemeController.to.primaryColor,
      offset: const Offset(20.0, 0),
      label: getBadgeCounter(lineCount, 'lines'),
      child: Text('$title '),
    ),
    border: const OutlineInputBorder(),
  );
}
