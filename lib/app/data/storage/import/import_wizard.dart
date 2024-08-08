import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:money/app/core/widgets/dialog/dialog.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/wizard_choice.dart';
import 'package:money/app/data/storage/import/import_qfx.dart';
import 'package:money/app/data/storage/import/import_qif.dart';
import 'package:money/app/data/storage/import/import_transactions_from_text.dart';

void showImportTransactionsWizard(
  final BuildContext context, [
  String? initialText,
]) {
  adaptiveScreenSizeDialog(
    context: context,
    captionForClose: 'Cancel',
    title: 'Import transactions',
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        WizardChoice(
          title: 'From QFX/QIF file',
          description: 'Use existing or downloaded files from local device.',
          onPressed: () {
            Navigator.of(context).pop(true);
            onImportFromFile(context);
          },
        ),
        gapHuge(),
        WizardChoice(
          title: 'Manual bulk text input',
          description:
              'Refer to your online statements, then Copy & Paste text or use OCR to extract the [Dates | Memos | Amounts].',
          onPressed: () {
            Navigator.of(context).pop(true);
            showImportTransactionsFromTextInput(context);
          },
        ),
      ],
    ),
  );
}

void onImportFromFile(
  final BuildContext context,
) async {
  final FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(type: FileType.any);
  if (pickerResult != null) {
    if (context.mounted) {
      switch (pickerResult.files.single.extension?.toLowerCase()) {
        case 'qif':
          importQIF(context, pickerResult.files.single.path.toString());
        case 'qfx':
          importQFX(context, pickerResult.files.single.path.toString());
      }
    }
  }
}
