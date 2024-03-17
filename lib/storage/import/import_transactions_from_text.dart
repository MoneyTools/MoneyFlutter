import 'package:flutter/material.dart';
import 'package:money/helpers/date_helper.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/models/settings.dart';
import 'package:money/models/value_parser.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/import/import_transactions_panel.dart';
import 'package:money/widgets/dialog_button.dart';
import 'package:money/widgets/dialog_full_screen.dart';
import 'package:money/widgets/message_box.dart';

void showImportTransactions(
  final BuildContext context, [
  String? initialText,
]) {
  initialText ??= '${dateToString(DateTime.now())} memo 1.00';

  Account? account = Settings().mostRecentlySelectedAccount;
  account ??= Data().accounts.firstItem();

  if (account == null) {
    messageBox(context, 'No account to import transaction to.');
  } else {
    ValuesParser parser = ValuesParser();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          // Full screen form
          return AutoSizeDialog(
            child: Column(
              children: [
                Expanded(
                  child: ImportTransactionsPanel(
                    account: account!,
                    inputText: initialText!,
                    onAccountChanged: (Account accountSelected) {
                      account = accountSelected;
                      Settings().mostRecentlySelectedAccount = accountSelected;
                    },
                    onTransactionsFound: (final ValuesParser newParser) {
                      parser.lines = newParser.lines;
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                                  account!,
                                  triple.date.asDate(),
                                  triple.description.asString(),
                                  triple.amount.asAmount(),
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
                ),
              ],
            ),
          );
        });
  }
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
