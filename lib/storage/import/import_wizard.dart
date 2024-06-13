import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/import/import_pdf.dart';
import 'package:money/storage/import/import_qfx.dart';
import 'package:money/storage/import/import_qif.dart';
import 'package:money/storage/import/import_transactions_from_text.dart';
import 'package:money/widgets/dialog/dialog.dart';
import 'package:money/widgets/gaps.dart';
import 'package:money/widgets/wizard_choice.dart';

void showImportTransactionsWizard(
  final BuildContext context, [
  String? initialText,
]) {
  adaptiveScreenSizeDialog(
    context: context,
    captionForClose: 'Cancel',
    title: 'Import transactons',
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        WizardChoice(
          title: 'From QFX file',
          description: 'Locate the file on your device.',
          onPressed: () {
            Navigator.of(context).pop(true);
            onImportFromFile();
          },
        ),
        gapHuge(),
        WizardChoice(
          title: 'Manual bulk text input',
          description: 'Copy paste text from online statements in the form of [Date | Memo | Amount].',
          onPressed: () {
            Navigator.of(context).pop(true);
            showImportTransactionsFromTextInput(context);
          },
        ),
      ],
    ),
  );
}

void onImportFromFile() async {
  final FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(type: FileType.any);
  if (pickerResult != null) {
    switch (pickerResult.files.single.extension?.toLowerCase()) {
      case 'qif':
        importQIF(pickerResult.files.single.path.toString());
      case 'qfx':
        importQFX(pickerResult.files.single.path.toString(), Data());
      case 'pdf':
        importPDF(pickerResult.files.single.path.toString(), Data());
    }
  }
}
