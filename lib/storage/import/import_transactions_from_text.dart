import 'package:flutter/material.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/models/settings.dart';
import 'package:money/models/value_parser.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/import/import_transactions_panel.dart';
import 'package:money/widgets/dialog_button.dart';
import 'package:money/widgets/message_box.dart';

import 'package:money/widgets/widgets.dart';

void importTransactionFromText(
  final BuildContext context,
  final String startingInputText,
  Account account,
) {
  ValueParser parser = ValueParser();

  myShowDialog(
    context: context,
    title: 'Add transactions',
    // We use a Cancel button
    includeCloseButton: false,

    child: ImportTransactionsPanel(
        account: account,
        inputText: startingInputText,
        onAccountChanged: (Account accountSelected) {
          account = accountSelected;
        },
        onTransactionsFound: (final ValueParser newParser) {
          parser.lines = newParser.lines;
        }),
    actionButtons: [
      DialogActionButton(
          text: 'Import',
          onPressed: () {
            if (parser.isEmpty) {
              messageBox(context, 'Nothing to import');
            } else {
              if (parser.containsErrors()) {
                messageBox(context, 'Contains errors');
              } else {
                // Import
                for (final triple in parser.lines) {
                  addTransactionFromDateDescriptionAmount(
                    account,
                    triple.values[0].asDate(),
                    triple.values[1].asString(),
                    triple.values[2].asAmount(),
                  );
                }
                Settings().fireOnChanged();
                Navigator.of(context).pop(false);
              }
            }
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
