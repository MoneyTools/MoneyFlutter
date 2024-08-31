import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/snack_bar.dart';

class PasteImageOcr extends StatefulWidget {
  const PasteImageOcr({
    super.key,
    required this.textController,
    required this.allowedCharacters,
  });

  final String allowedCharacters;
  final TextEditingController textController;

  @override
  State<PasteImageOcr> createState() => _PasteImageOcrState();
}

class _PasteImageOcrState extends State<PasteImageOcr> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        SnackBarService.displayWarning(
          title: 'OCR Support',
          message: 'OCR is not yet supported on Web version of MyMoney',
        );
      },
      child: const Text('Paste OCR'),
    );
  }
}
