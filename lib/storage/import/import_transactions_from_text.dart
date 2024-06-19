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
import 'package:money/widgets/snack_bar.dart';

void showImportTransactionsFromTextInput(
  final BuildContext context, [
  String? initialText,
]) {
  initialText ??= '';

  Account account = Data().accounts.getMostRecentlySelectedAccount();

  ValuesParser parser = ValuesParser();

  List<Widget> actionButtons = [
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
              final List<Transaction> transactionsToAdd = [];
              for (final ValuesQuality singleTransactionInput in parser.lines) {
                if (!singleTransactionInput.exist) {
                  final t = createNewTransactionFromDateDescriptionAmount(
                    account,
                    singleTransactionInput.date.asDate(),
                    singleTransactionInput.description.asString(),
                    singleTransactionInput.amount.asAmount(),
                  );
                  transactionsToAdd.add(t);
                }
              }
              addNewTransactions(transactionsToAdd, '${transactionsToAdd.length} transactions added');

              Navigator.of(context).pop(false);
            }
          }
        }),
  ];

  adaptiveScreenSizeDialog(
    context: context,
    title: 'Import from text',
    captionForClose: 'Cancel',
    actionButtons: actionButtons,
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
      ],
    ),
  );
}

Transaction createNewTransactionFromDateDescriptionAmount(
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
  t.amount.value.setAmount(amount);
  return t;
}

/// Add the list of transactions "as is", then notify the user when completed
/// Note that this does not check for duplicated transaction or resolvs the Payee names
void addNewTransactions(List<Transaction> transactionsNew, String messageToUserAfterAdding) {
  if (transactionsNew.isEmpty) {
    SnackBarService.displayWarning(
      autoDismiss: true,
      message: messageToUserAfterAdding,
    );
    return;
  }

  for (final transactionToAdd in transactionsNew) {
    Data().transactions.appendNewMoneyObject(transactionToAdd, fireNotification: false);
  }
  Data().updateAll();

  SnackBarService.displaySuccess(
    autoDismiss: true,
    message: messageToUserAfterAdding,
  );
}
