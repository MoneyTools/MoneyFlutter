import 'package:flutter/material.dart';
import 'package:money/core/helpers/string_helper.dart';
import 'package:money/core/widgets/box.dart';
import 'package:money/core/widgets/columns/columns_input.dart';
import 'package:money/core/widgets/ocr.dart';
import 'package:money/data/models/constants.dart';

class InputValues extends StatelessWidget {
  const InputValues({
    super.key,
    required this.controller,
    required this.title,
    required this.allowedCharacters,
  });

  final String allowedCharacters;
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
          header: buildHeaderTitleAndCounter(context, title, '${getIntAsText(lineCount)} lines'),
          child: TextField(
            key: const Key('key_input_text_field_value'),
            controller: controller,
            // focusNode: focusNode,
            autofocus: false,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontSize: SizeForText.medium,
              overflow: TextOverflow.fade,
            ),
            inputFormatters: [
              TextInputFormatterRemoveEmptyLines(), // remove empty line
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: PasteImageOcr(
            textController: controller,
            allowedCharacters: allowedCharacters,
          ),
        ),
      ],
    );
  }
}
