import 'package:flutter/material.dart';
import 'package:money/app/data/models/money_objects/money_object.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/core/widgets/confirmation_dialog.dart';
import 'package:money/app/core/widgets/dialog/dialog_button.dart';
import 'package:money/app/core/widgets/dialog/dialog_full_screen.dart';

Future<dynamic> showTransactionAndActions({
  required final BuildContext context,
  required final Transaction transaction,
}) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogMutateTransaction(transaction: transaction);
      });
}

/// Dialog content
class DialogMutateTransaction extends StatefulWidget {
  final Transaction transaction;

  const DialogMutateTransaction({
    super.key,
    required this.transaction,
  });

  @override
  State<DialogMutateTransaction> createState() => _DialogMutateTransactionState();
}

class _DialogMutateTransactionState extends State<DialogMutateTransaction> {
  bool isInEditingMode = false;
  bool dataWasModified = false;
  late Transaction _transaction;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  @override
  Widget build(final BuildContext context) {
    return AutoSizeDialog(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _transaction.buildWidgets(
                  onEdit: isInEditingMode
                      ? () {
                          setState(() {
                            dataWasModified = isDataModified();
                          });
                        }
                      : null,
                ),
              ),
            ),
          ),
          dialogActionButtons(
            getActionButtons(
              context: context,
              transaction: _transaction,
              editMode: isInEditingMode,
              dataWasModified: dataWasModified,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getActionButtons({
    required BuildContext context,
    required Transaction transaction,
    required bool editMode,
    required bool dataWasModified,
  }) {
    if (editMode) {
      return [
        DialogActionButton(
            text: dataWasModified ? 'Apply' : 'Done',
            onPressed: () {
              // Changes were made
              if (dataWasModified) {
                Data().notifyMutationChanged(mutation: MutationType.changed, moneyObject: transaction);
              }
              Navigator.of(context).pop(true);
            })
      ];
    }

    // Read only more
    return [
      // Close
      DialogActionButton(
          text: 'Close',
          onPressed: () {
            Navigator.of(context).pop(false);
          }),
      // Delete
      DialogActionButton(
        icon: Icons.delete_outlined,
        text: 'Delete',
        onPressed: () {
          showConfirmationDialog(
            context: context,
            title: 'Delete Transaction',
            question: 'Are you sure you want to delete this transaction?',
            content: Column(
              children: transaction.buildWidgets(onEdit: null, compact: true),
            ),
            buttonText: 'Delete',
            onConfirmation: () {
              Data().transactions.deleteItem(transaction);
              Navigator.of(context).pop(false);
            },
          );
        },
      ),
      // Duplicate
      DialogActionButton(
        icon: Icons.copy_outlined,
        text: 'Duplicate',
        onPressed: () {
          _transaction = Transaction()
            ..id.value = -1
            ..accountId.value = transaction.accountId.value
            ..dateTime.value = transaction.dateTime.value
            ..payee.value = transaction.payee.value
            ..categoryId.value = transaction.categoryId.value
            ..transfer = transaction.transfer
            ..amount.value = transaction.amount.value
            ..memo.value = transaction.memo.value;

          setState(() {
            // append to the list of transactions
            Data().transactions.appendNewMoneyObject(_transaction);
            isInEditingMode = true;
          });
        },
      ),
      // Edit
      DialogActionButton(
        icon: Icons.edit_outlined,
        text: 'Edit',
        onPressed: () {
          transaction.stashValueBeforeEditing();
          setState(() {
            isInEditingMode = true;
          });
        },
      ),
    ];
  }

  bool isDataModified() {
    MyJson afterEditing = _transaction.getPersistableJSon();
    MyJson diff = myJsonDiff(before: _transaction.valueBeforeEdit ?? {}, after: afterEditing);
    return diff.keys.isNotEmpty;
  }
}
