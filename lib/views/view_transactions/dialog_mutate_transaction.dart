import 'package:flutter/material.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/widgets/confirmation_dialog.dart';
import 'package:money/widgets/dialog_button.dart';
import 'package:money/widgets/dialog_full_screen.dart';

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
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _transaction.buildWidgets<Transaction>(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: getActionButtons(
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
        // if (dataWasModified)
        //   DialogActionButton(
        //       text: 'Discard',
        //       onPressed: () {
        //         Navigator.of(context).pop(false);
        //       }),
        DialogActionButton(
            text: dataWasModified ? 'Apply' : 'Close',
            onPressed: () {
              // Changes were made
              if (dataWasModified) {
                Data().notifyTransactionChange(mutation: MutationType.changed, moneyObject: transaction);
              }
              Navigator.of(context).pop(true);
            })
      ];
    }

    // Read only more
    return [
      // Delete
      DialogActionButton(
        text: 'Delete',
        onPressed: () {
          showDialog(
            context: context,
            builder: (final BuildContext context) {
              return Center(
                child: DeleteConfirmationDialog(
                  title: 'Delete',
                  question: 'Are you sure you want to delete this?',
                  content: Column(
                    children: transaction.buildWidgets<Transaction>(onEdit: null, compact: true),
                  ),
                  onConfirm: () {
                    Data().transactions.deleteItem(transaction);
                    Navigator.of(context).pop(false);
                  },
                ),
              );
            },
          );
        },
      ),
      // Duplicate
      DialogActionButton(
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
        text: 'Edit',
        onPressed: () {
          transaction.stashValueBeforeEditing<Transaction>();
          setState(() {
            isInEditingMode = true;
          });
        },
      ),
      // Close
      DialogActionButton(
          text: 'Close',
          onPressed: () {
            Navigator.of(context).pop(false);
          }),
    ];
  }

  bool isDataModified() {
    if (_transaction.valueBeforeEdit != null) {
      MyJson afterEditing = _transaction.getPersistableJSon<Transaction>();
      MyJson diff = myJsonDiff(_transaction.valueBeforeEdit!, afterEditing);
      if (diff.keys.isNotEmpty) {
        return true;
      }
    }
    return false;
  }
}
