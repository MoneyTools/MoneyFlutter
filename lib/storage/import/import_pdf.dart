import 'dart:io';

import 'package:dart_pdf_reader/dart_pdf_reader.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/storage/data/data.dart';

Future<void> importPDF(
  final String filePath,
  final Data data,
) async {
  final File file = File(filePath);

  final ByteStream stream = ByteStream(file.readAsBytesSync());
  // or stream = BufferedRandomAccessStream(FileStream(await File(inputFile).open()));

  final PDFDocument doc = await PDFParser(stream).parse();

  final PDFDocumentCatalog catalog = await doc.catalog;

  final PDFPages pages = await catalog.getPages();

  // final List<PDFOutlineItem>? outlines = await catalog.getOutlines();

  for (int pageIndex = 0; pageIndex < pages.pageCount; pageIndex++) {
    final PDFPageObjectNode page = pages.getPageAtIndex(pageIndex);
    debugLog('$pageIndex $page');
    final PDFDictionary? rs = await page.resources;
    if (rs != null) {
      rs.entries.forEach((key, value) {
        debugLog(key.toString());
      });
    }
  }
}
