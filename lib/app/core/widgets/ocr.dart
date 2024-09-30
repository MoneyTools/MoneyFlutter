import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/widgets/snack_bar.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:textify/image_pipeline.dart';
import 'package:textify/textify.dart';

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

  Future<ui.Image> fromBytesToImage(Uint8List list) async {
    // Decode the image
    final codec = await ui.instantiateImageCodec(list);
    final FrameInfo frameInfo = await codec.getNextFrame();

    return frameInfo.image;
  }

  Future<void> _recognizeTextFromClipboard() async {
    final Uint8List? bytes = await Pasteboard.image;
    if (bytes != null) {
      try {
        final Textify textify = Textify();
        await textify.init();

        final inputImage = await fromBytesToImage(bytes);
        final ImagePipeline interimImages = await ImagePipeline.apply(inputImage);
        widget.textController.text = textify.getTextFromBinaryImage(
          imageAsBinary: interimImages.imageBinary,
          supportedCharacters: widget.allowedCharacters,
        );
      } on Exception catch (e) {
        // Handle potential errors
        logger.e('Error recognizing text: $e');
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
