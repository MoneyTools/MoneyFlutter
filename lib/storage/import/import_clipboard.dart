import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/import/import_clipboard_panel.dart';
import 'package:money/widgets/dialog_button.dart';
import 'package:money/widgets/semantic_text.dart';
import 'package:money/widgets/widgets.dart';

void importTransactionFromClipboardText(
  final BuildContext context,
  String rawDataFromClipboard,
  Account account,
) {
  rawDataFromClipboard = rawDataFromClipboard.trim();
  List<String> lines = rawDataFromClipboard.trim().split(RegExp(r'\r?\n|\r'));

  String errorMessage = '';

  List<List<ValueQuality>> values = [];
  List<Widget> rows = [];

  if (lines.isEmpty) {
    errorMessage = 'Empty content';
  } else {
    for (var line in lines) {
      List<String> threeValues = line.split('\t');

      if (threeValues.length == 3) {
        List<ValueQuality> triples = [];
        triples.add(ValueQuality(threeValues[0]));
        triples.add(ValueQuality(threeValues[1]));
        triples.add(ValueQuality(threeValues[2]));
        values.add(triples);

        rows.add(
          Row(children: [
            SizedBox(width: 100, child: triples[0].valueAsDateWidget(context)), // Date
            SizedBox(width: 300, child: triples[1].valueAsTextWidget(context)), // Description
            SizedBox(width: 100, child: triples[2].valueAsAmountWidget(context)), // Amount
          ]),
        );
      } else {
        errorMessage =
            'The data in your clipboard does not appear to match the expected format of [Date] [Description] [Amount]';
        break;
      }
    }
  }

  Widget widgetToPresentToUser =
      rows.isEmpty ? buildWarning(context, '$errorMessage\n\n"$rawDataFromClipboard"') : Column(children: rows);

  myShowDialog(
    context: context,
    title: 'Import transactions',
    includeCloseButton: false,
    // We use a Cancel button
    child: ImportClipboardPanel(
      rawInputText: rawDataFromClipboard,
      account: account,
      onAccountChanged: (Account accountSelected) {
        account = accountSelected;
      },
      child: widgetToPresentToUser,
    ),
    actionButtons: [
      if (rows.isNotEmpty)
        DialogActionButton(
            text: 'Import',
            onPressed: () {
              // Import
              for (final triple in values) {
                addTransactionFromDateDescriptionAmount(
                  account,
                  triple[0].asDate(),
                  triple[1].asString(),
                  triple[2].asAmount(),
                );
              }
              Settings().fireOnChanged();
              Navigator.of(context).pop(false);
            }),
      DialogActionButton(
          text: 'Cancel',
          onPressed: () {
            Navigator.of(context).pop(false);
          }),
    ],
  );
}

void addTransactionFromDateDescriptionAmount(
  final Account account,
  final DateTime date,
  final String description,
  final double amount,
) {
  Payee? payee = Data().aliases.findByMatch(description);

  final Transaction t = Transaction();
  t.id.value = Data().transactions.getNextTransactionId();
  t.accountId.value = account.id.value;
  t.dateTime.value = date;
  t.payeeId.value = payee == null ? -1 : payee.id.value;
  t.memo.value = description;
  t.amount.value = amount;

  Data().transactions.addEntry(t, isNewEntry: true);
}

class ValueQuality {
  double? valueAsDouble;
  final String valueAsString;

  String warningMessage = '';

  ValueQuality(this.valueAsString);

  DateTime asDate() {
    return attemptToGetDateFromText(valueAsString) ?? DateTime.now();
  }

  String asString() {
    return valueAsString;
  }

  double asAmount() {
    return attemptToGetDoubleFromText(valueAsString) ?? 0.00;
  }

  Widget valueAsDateWidget(final BuildContext context) {
    final parsedDate = attemptToGetDateFromText(valueAsString);
    if (parsedDate == null) {
      return buildWarning(context, valueAsString);
    }

    String dateText = DateFormat('yyyy-MM-dd').format(parsedDate);
    return SelectableText(dateText);
  }

  Widget valueAsTextWidget(final BuildContext context) {
    return SelectableText(valueAsString);
  }

  Widget valueAsAmountWidget(final BuildContext context) {
    double? amount = attemptToGetDoubleFromText(valueAsString);
    if (amount == null) {
      return buildWarning(context, valueAsString);
    }
    return SelectableText(
      doubleToCurrency(amount),
      textAlign: TextAlign.right,
    );
  }
}
