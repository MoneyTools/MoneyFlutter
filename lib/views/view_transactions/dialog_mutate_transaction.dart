import 'package:flutter/material.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/widgets/confirmation_dialog.dart';
import 'package:money/widgets/details_panel/details_panel_fields.dart';
import 'package:money/widgets/dialog_button.dart';
import 'package:money/widgets/dialog_full_screen.dart';

Future<dynamic> showTransactionAndActions({
  required final BuildContext context,
  required final Transaction transaction,
  // passing null to this call weill make it ReadOnly
  required final Function(
    MutationType typeOfMutation,
    Transaction instanceOfItemMutated,
  ) onDataMutated,
}) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogMutateTransaction(transaction: transaction, onDataMutated: onDataMutated);
      });
}

/// Dialog content
class DialogMutateTransaction extends StatefulWidget {
  final Transaction transaction;
  final Function(
    MutationType typeOfMutation,
    Transaction instanceOfItemMutated,
  ) onDataMutated;

  const DialogMutateTransaction({
    super.key,
    required this.transaction,
    required this.onDataMutated,
  });

  @override
  State<DialogMutateTransaction> createState() => _DialogMutateTransactionState();
}

class _DialogMutateTransactionState extends State<DialogMutateTransaction> {
  bool isInEditingMode = false;

  @override
  Widget build(final BuildContext context) {
    final List<Field<Transaction, dynamic>> fields = getFieldsForClass<Transaction>()
        .where((final Field<Transaction, dynamic> item) => item.useAsDetailPanels)
        .toList();

    final Fields<Transaction> detailPanelFields = Fields<Transaction>(definitions: fields);

    return AutoSizeDialog(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: DetailsPanelFields<Transaction>(
                instance: widget.transaction,
                detailPanelFields: detailPanelFields,
                isReadOnly: !isInEditingMode,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: getActionButtons(
              context,
              widget.transaction,
              detailPanelFields,
              isInEditingMode ? widget.onDataMutated : null,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getActionButtons(
    BuildContext context,
    Transaction instance,
    Fields<Transaction> detailPanelFields,
    Function(
      MutationType typeOfMutation,
      Transaction instanceOfItemMutated,
    )? onDataMutated,
  ) {
    bool editMode = onDataMutated != null;

    if (editMode) {
      return [
        // DialogActionButton(
        //     text: 'Discard',
        //     onPressed: () {
        //       Navigator.of(context).pop(false);
        //     }),
        DialogActionButton(
            text: 'Apply',
            onPressed: () {
              onDataMutated(MutationType.changed, instance);
              Navigator.of(context).pop(false);
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
                    children: detailPanelFields.getListOfFieldNameAndValuePairAsWidget(instance),
                  ),
                  onConfirm: () {
                    Data().transactions.deleteItem(instance);
                    Navigator.of(context).pop(false);
                    onDataMutated?.call(MutationType.deleted, instance);
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
          final Transaction t = Transaction()
            ..id.value = Data().transactions.getNextTransactionId()
            ..accountId.value = instance.accountId.value
            ..dateTime.value = instance.dateTime.value
            ..payeeId.value = instance.payeeId.value
            ..payeeInstance = instance.payeeInstance
            ..categoryId.value = instance.categoryId.value
            ..transfer = instance.transfer
            ..amount.value = instance.amount.value
            ..memo.value = instance.memo.value;
          Data().transactions.addEntry(t, isNewEntry: true);
          Navigator.of(context).pop(false);
          onDataMutated?.call(MutationType.inserted, t);
        },
      ),
      // Edit
      DialogActionButton(
        text: 'Edit',
        onPressed: () {
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
}
