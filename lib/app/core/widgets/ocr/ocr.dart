import 'package:money/app/core/widgets/ocr/ocr_supported.dart'
    if (dart.library.html) 'package:money/app/core/widgets/ocr/ocr_web.dart';

class PasteOcr extends PasteImageOcr {
  const PasteOcr({super.key, required super.textController});
}
