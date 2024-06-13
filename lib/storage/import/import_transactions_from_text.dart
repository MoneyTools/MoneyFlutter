import 'package:flutter/material.dart';
import 'package:money/helpers/value_parser.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/import/import_transactions_panel.dart';
import 'package:money/widgets/dialog/dialog.dart';
import 'package:money/widgets/dialog/dialog_button.dart';
import 'package:money/widgets/gaps.dart';
import 'package:money/widgets/message_box.dart';

void showImportTransactionsFromTextInput(
  final BuildContext context, [
  String? initialText,
]) {
  initialText ??= '';

  Account account = Data().accounts.getMostRecentlySelectedAccount();

  ValuesParser parser = ValuesParser();

  adaptiveScreenSizeDialog(
    context: context,
    captionForClose: null, // this will hide the close button
    title: 'Import from text',
    child: Column(
      children: [
        gapLarge(),
        Expanded(
          child: ImportTransactionsPanel(
            account: account,
            inputText: initialText,
            onAccountChanged: (Account accountSelected) {
              account = accountSelected;
              Data().accounts.setMostRecentUsedAccount(accountSelected);
            },
            onTransactionsFound: (final ValuesParser newParser) {
              parser.lines = newParser.lines;
            },
          ),
        ),

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Button - Cancel
            DialogActionButton(
              text: 'Cancel',
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // Button - Import
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
                          triple.date.asDate(),
                          triple.description.asString(),
                          triple.amount.asAmount(),
                        );
                      }
                      Data().updateAll();
                      Navigator.of(context).pop(false);
                    }
                  }
                }),
          ],
        ),
      ],
    ),
  );
}

void addTransactionFromDateDescriptionAmount(
  final Account account,
  final DateTime date,
  final String description,
  final double amount,
) {
  Payee? payee = Data().aliases.findOrCreateNewPayee(description, fireNotification: false);

  final Transaction t = Transaction();
  t.id.value = -1;
  t.accountId.value = account.id.value;
  t.dateTime.value = date;
  t.payee.value = payee == null ? -1 : payee.id.value;
  t.memo.value = description;
  t.amount.value.amount = amount;

  Data().transactions.appendNewMoneyObject(t, fireNotification: false);
}
