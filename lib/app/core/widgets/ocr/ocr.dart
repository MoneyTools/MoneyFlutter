import 'package:money/app/core/widgets/ocr/ocr_supported.dart'
    if (dart.library.html) 'package:money/app/core/widgets/ocr/ocr_web.dart';

/// Allowed Characters
/// Dates '0123456789/\-.'
/// Amount value > '()01234567890,.'
class PasteOcr extends PasteImageOcr {
  const PasteOcr({super.key, required super.textController, required super.allowedCharacters});
}
