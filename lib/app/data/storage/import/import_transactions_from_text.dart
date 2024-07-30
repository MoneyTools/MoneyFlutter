import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/value_parser.dart';
import 'package:money/app/core/widgets/dialog/dialog.dart';
import 'package:money/app/core/widgets/dialog/dialog_button.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/message_box.dart';
import 'package:money/app/core/widgets/snack_bar.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/payees/payee.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/data/storage/import/import_transactions_panel.dart';

void showImportTransactionsFromTextInput(
  final BuildContext context, [
  String? initialText,
]) {
  initialText ??= '';

  Account account = Data().accounts.getMostRecentlySelectedAccount();

  ValuesParser parser = ValuesParser(dateFormat: 'MM/dd/yyyy', currency: 'USD');

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
                  singleTransactionInput.date.asDate() ?? DateTime.now(),
                  singleTransactionInput.description.asString(),
                  singleTransactionInput.amount.asAmount(),
                );
                transactionsToAdd.add(t);
              }
            }
            addNewTransactions(
              transactionsToAdd,
              '${transactionsToAdd.length} transactions added',
            );

            Navigator.of(context).pop(false);
          }
        }
      },
    ),
  ];

  adaptiveScreenSizeDialog(
    context: context,
    captionForClose: 'Cancel',
    actionButtons: actionButtons,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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

  final Transaction t = Transaction(date: date);
  t.fieldId.value = -1;
  t.fieldAccountId.value = account.fieldId.value;
  t.fieldPayee.value = payee == null ? -1 : payee.fieldId.value;
  t.fieldMemo.value = description;
  t.fieldAmount.value.setAmount(amount);
  return t;
}

/// Add the list of transactions "as is", then notify the user when completed
/// Note that this does not check for duplicated transaction or resolvs the Payee names
void addNewTransactions(
  List<Transaction> transactionsNew,
  String messageToUserAfterAdding,
) {
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
    title: 'Import',
    message: messageToUserAfterAdding,
  );
}
