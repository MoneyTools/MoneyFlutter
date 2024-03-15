import 'package:flutter/material.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/widgets/confirmation_dialog.dart';
import 'package:money/widgets/details_panel/details_panel_fields2.dart';
import 'package:money/widgets/dialog_button.dart';
import 'package:money/widgets/dialog_full_screen.dart';

void showTransactionAndActions(
  final BuildContext context,
  final Transaction instance,
) {
  final List<Field<Transaction, dynamic>> fields = getFieldsForClass<Transaction>()
      .where((final Field<Transaction, dynamic> item) => item.useAsDetailPanels)
      .toList();

  final Fields<Transaction> detailPanelFields = Fields<Transaction>(definitions: fields);

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyFullDialog(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: DetailsPanelFields2<Transaction>(instance: instance, detailPanelFields: detailPanelFields),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
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
                      Navigator.of(context).pop(true);
                    },
                  ),
                  DialogActionButton(
                      text: 'Close',
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      }),
                ],
              ),
            ],
          ),
        );
      });
}
