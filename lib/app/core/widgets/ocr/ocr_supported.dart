import 'dart:io';

import 'package:flusseract/flusseract.dart' as flusseract;
import 'package:flusseract/tessdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/snack_bar.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';

class PasteImageOcr extends StatefulWidget {
  const PasteImageOcr({
    super.key,
    required this.textController,
    required this.allowedCharacters,
  });

  final TextEditingController textController;
  final String allowedCharacters;

  @override
  State<PasteImageOcr> createState() => _PasteImageOcrState();
}

class _PasteImageOcrState extends State<PasteImageOcr> {
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.6, // Adjust scale factor as needed (0.0 to 1.0)
      alignment: Alignment.bottomCenter, // Optional: Position the scaled button
      child: ElevatedButton.icon(
        onPressed: _recognizeTextFromClipboard,
        icon: const Icon(Icons.content_paste_go_outlined),
        label: const Text('OCR'),
      ),
    );
  }

  Future<void> _recognizeTextFromClipboard() async {
    final bytes = await Pasteboard.image;
    if (bytes != null) {
      try {
        // final Directory tempDir = await getTemporaryDirectory();
        // final File file = await File('${tempDir.path}/pasted_image.png').writeAsBytes(bytes);

        await TessData.init();

        final image = flusseract.PixImage.fromBytes(bytes);
        final tesseract = flusseract.Tesseract(
          tessDataPath: TessData.tessDataPath,
        );

        tesseract.setWhiteList(widget.allowedCharacters);
        tesseract.utf8Text(image).then((ocrText) {
          widget.textController.text = removeEmptyLines('${widget.textController.text}\n$ocrText');
        });
      } on Exception catch (e) {
        // Handle potential errors
        debugLog('Error recognizing text: $e');
        SnackBarService.displayError(
          message: 'Failed to extract text from image.',
        );
      }
    } else {
      SnackBarService.displayError(
        title: 'OCR',
        message: 'No image found in clipboard.',
      );
    }
  }
}

Future<String> loadTesseractData() async {
  try {
    final data = await rootBundle.load('assets/tessdata/eng.traineddata');
    final bytes = data.buffer.asUint8List();
    return String.fromCharCodes(bytes); // Convert bytes to string
  } on Exception catch (e) {
    debugLog('Error loading Tesseract data: $e');
    return ''; // Handle errors gracefully (e.g., display an error message)
  }
}
