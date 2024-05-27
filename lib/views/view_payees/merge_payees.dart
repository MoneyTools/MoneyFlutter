import 'package:flutter/material.dart';
import 'package:money/helpers/accumulator.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/models/money_objects/payees/payees.dart';
import 'package:money/models/money_objects/transactions/transactions.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_payees/picker_payee.dart';
import 'package:money/widgets/dialog/dialog_button.dart';
import 'package:money/widgets/gaps.dart';

class MergeTransactionsDialog extends StatefulWidget {
  const MergeTransactionsDialog({
    super.key,
    required this.currentPayee,
    required this.transactions,
  });

  final Payee currentPayee;
  final List<Transaction> transactions;

  @override
  State<MergeTransactionsDialog> createState() => _MergeTransactionsDialogState();
}

class _MergeTransactionsDialogState extends State<MergeTransactionsDialog> {
  Payee? _selectedPayee;

  bool _changeCategoryToDestinationPayee = true;
  int? _estimatedCategory;

  @override
  Widget build(BuildContext context) {
    // evaluate Category of the destination
    _estimatedCategory = null;

    if (_selectedPayee != null) {
      AccumulatorSum<int, int> categoryIdsFound = AccumulatorSum<int, int>();

      for (final t in Data().transactions.iterableList(includeDeleted: true)) {
        if (t.payee.value == _selectedPayee!.uniqueId) {
          categoryIdsFound.cumulate(t.categoryId.value, 1);
        }
      }
      _estimatedCategory = categoryIdsFound.getKeyWithLargestSum();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('From "${widget.currentPayee.name.value}"'),
        gapLarge(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('To '),
            Expanded(
              child: pickerPayee(
                itemSelected: widget.currentPayee,
                onSelected: (final Payee? selectedPayee) {
                  setState(() {
                    _selectedPayee = selectedPayee;
                  });
                },
              ),
            ),
          ],
        ),
        gapLarge(),
        if (_estimatedCategory != null && _estimatedCategory != -1)
          CheckboxListTile(
            value: _changeCategoryToDestinationPayee,
            onChanged: (bool? value) {
              // Handle the change event
              setState(() {
                _changeCategoryToDestinationPayee = value == true;
              });
            },
            title: Text('Match destination category\n"${Data().categories.getNameFromId(_estimatedCategory!)}"'),
            dense: true,
          ),
        const Spacer(),
        dialogActionButtons(
          [
            DialogActionButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(context),
            ),
            if (_selectedPayee != null && _selectedPayee != widget.currentPayee)
              DialogActionButton(
                text: 'Merge',
                onPressed: () {
                  mutateTransactionsToPayee(
                    widget.transactions,
                    _selectedPayee!.uniqueId,
                    _changeCategoryToDestinationPayee == true ? _estimatedCategory : null,
                  );
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ],
    );
  }
}

void mutateTransactionsToPayee(final List<Transaction> transactions, final int toPayeeId, final int? categoryId) {
  Set<int> fromPayeeIds = {};

  for (final t in transactions) {
    // keep track of the payeeIds that we remove transactions from
    fromPayeeIds.add(t.payee.value);

    t.stashValueBeforeEditing();

    t.payee.value = toPayeeId;
    if (categoryId != null) {
      t.categoryId.value = categoryId;
    }

    Data().notifyMutationChanged(
      mutation: MutationType.changed,
      moneyObject: t,
      fireNotification: false,
    );
  }
  Payees.removePayeesThatHaveNoTransactions(fromPayeeIds.toList());
  Data().updateAll();
}
