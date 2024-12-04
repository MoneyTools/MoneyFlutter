import 'package:flutter/material.dart';
import 'package:money/core/widgets/confirmation_dialog.dart';
import 'package:money/core/widgets/dialog/dialog_button.dart';
import 'package:money/core/widgets/dialog/dialog_full_screen.dart';
import 'package:money/data/models/money_objects/transactions/transaction.dart';
import 'package:money/data/storage/data/data.dart';

Future<dynamic> showTransactionAndActions({
  required final BuildContext context,
  required final Transaction transaction,
}) {
  return showDialog(
    context: context,
    builder: (final BuildContext context) {
      return DialogMutateTransaction(transaction: transaction);
    },
  );
}

/// Dialog content
class DialogMutateTransaction extends StatefulWidget {
  const DialogMutateTransaction({
    required this.transaction,
    super.key,
  });

  final Transaction transaction;

  @override
  State<DialogMutateTransaction> createState() => _DialogMutateTransactionState();
}

class _DialogMutateTransactionState extends State<DialogMutateTransaction> {
  bool dataWasModified = false;
  bool isInEditingMode = false;

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
                children: _transaction.buildListOfNamesValuesWidgets(
                  onEdit: isInEditingMode
                      ? (bool wasModified) {
                          setState(() {
                            dataWasModified = wasModified || isDataModified();
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
    required final BuildContext context,
    required final Transaction transaction,
    required final bool editMode,
    required final bool dataWasModified,
  }) {
    if (editMode) {
      return [
        DialogActionButton(
          key: Constants.keyButtonApplyOrDone,
          text: dataWasModified ? 'Apply' : 'Done',
          onPressed: () {
            // Changes were made
            if (dataWasModified) {
              Data().notifyMutationChanged(
                mutation: MutationType.changed,
                moneyObject: transaction,
              );
            }
            Navigator.of(context).pop(true);
          },
        ),
      ];
    }

    // Read only more
    return [
      // Close
      DialogActionButton(
        text: 'Close',
        onPressed: () {
          Navigator.of(context).pop(false);
        },
      ),
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
              children: transaction.buildListOfNamesValuesWidgets(compact: true),
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
          _transaction = Transaction(date: transaction.fieldDateTime.value)
            ..fieldId.value = -1
            ..fieldAccountId.value = transaction.fieldAccountId.value
            ..fieldPayee.value = transaction.fieldPayee.value
            ..fieldCategoryId.value = transaction.fieldCategoryId.value
            ..fieldTransfer = transaction.fieldTransfer
            ..fieldAmount.value = transaction.fieldAmount.value
            ..fieldMemo.value = transaction.fieldMemo.value;

          setState(() {
            // append to the list of transactions
            Data().transactions.appendNewMoneyObject(_transaction);
            isInEditingMode = true;
          });
        },
      ),
      // Edit
      DialogActionButton(
        key: Constants.keyButtonEdit,
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
    final MyJson afterEditing = _transaction.getPersistableJSon();
    final MyJson diff = myJsonDiff(
      before: _transaction.valueBeforeEdit ?? {},
      after: afterEditing,
    );
    return diff.keys.isNotEmpty;
  }
}
