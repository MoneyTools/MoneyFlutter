import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:money/core/widgets/dialog/dialog.dart';
import 'package:money/core/widgets/gaps.dart';
import 'package:money/core/widgets/wizard_choice.dart';
import 'package:money/data/storage/import/import_csv.dart'; // Added import
import 'package:money/data/storage/import/import_investment.dart';
import 'package:money/data/storage/import/import_qfx.dart';
import 'package:money/data/storage/import/import_qif.dart';
import 'package:money/data/storage/import/import_transactions_from_text.dart';
import 'package:money/data/storage/import/import_trasnsfer.dart';

void showImportTransactionsWizard() {
  final BuildContext originalContext = Get.context!; // Store the original context

  adaptiveScreenSizeDialog(
    context: originalContext, // Use original context for showing the dialog
    captionForClose: 'Cancel',
    title: 'Import transactions',
    child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 40,
        children: <Widget>[
          gapMedium(),
          WizardChoice(
            title: 'From QFX/QIF/CSV file', // Changed title
            description: 'Import transactions from a QFX, QIF, or CSV bank file.', // Changed description
            onPressed: () {
              Navigator.of(originalContext).pop(true); // Use originalContext
              onImportFromFile(originalContext); // Pass original, still-mounted context
            },
          ),
          WizardChoice(
            title: 'Manual bulk text input',
            description:
                'Refer to your online statements, then Copy & Paste text or use OCR to extract the [Dates | Memos | Amounts].',
            onPressed: () {
              Navigator.of(originalContext).pop(true); // Use originalContext
              showImportTransactionsFromTextInput(originalContext); // Use originalContext
            },
          ),
          WizardChoice(
            title: 'Record a transfer',
            description: 'add a transaction Between two accounts.',
            onPressed: () {
              Navigator.of(originalContext).pop(true); // Use originalContext
              showImportTransfer();
            },
          ),
          WizardChoice(
            title: 'Investment Transaction',
            description: 'Buy/Sell/Dividend.',
            onPressed: () {
              Navigator.of(originalContext).pop(true); // Use originalContext
              showImportInvestment();
            },
          ),
        ],
      ),
    ),
  );
}

void onImportFromFile(final BuildContext context) async {
  final FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(
    type: FileType.any,
  );
  if (pickerResult != null) {
    if (context.mounted) {
      switch (pickerResult.files.single.extension?.toLowerCase()) {
        case 'qif':
          importQIF(context, pickerResult.files.single.path.toString());
          break; // Added break
        case 'qfx':
          importQFX(context, pickerResult.files.single.path.toString());
          break; // Added break
        case 'csv': // Added csv case
          importCSV(context, pickerResult.files.single.path.toString());
          break;
      }
    }
  }
}
