import 'package:flutter/material.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/transactions/transactions.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_categories/picker_category.dart';
import 'package:money/widgets/box.dart';
import 'package:money/widgets/gaps.dart';

class MergeCategoriesTransactionsDialog extends StatefulWidget {
  const MergeCategoriesTransactionsDialog({
    super.key,
    required this.categoryToMove,
  });

  final Category categoryToMove;

  @override
  State<MergeCategoriesTransactionsDialog> createState() => _MergeCategoriesTransactionsDialogState();
}

class _MergeCategoriesTransactionsDialogState extends State<MergeCategoriesTransactionsDialog> {
  late Category _categoryPicked = widget.categoryToMove;
  final List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();

    for (final t in Data().transactions.iterableList(includeDeleted: true)) {
      if (t.categoryId.value == widget.categoryToMove.uniqueId) {
        _transactions.add(t);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Move ${_transactions.length} transactions'),
      content: SizedBox(
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            gapLarge(),
            gapLarge(),
            Text('From "${widget.categoryToMove.name.value}"'),
            gapLarge(),
            gapLarge(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('To '),
                Expanded(
                  child: pickerCategory(
                    itemSelected: widget.categoryToMove,
                    onSelected: (final Category? newSelection) {
                      setState(() {
                        _categoryPicked = newSelection!;
                      });
                    },
                  ),
                ),
              ],
            ),
            gapLarge(),
            gapLarge(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Opacity(
                opacity: 0.5,
                child: _buildLearning(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Cancel
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),

        // Append
        ElevatedButton(
          onPressed: () {
            if (_categoryPicked == widget.categoryToMove) {
              showSnackBar(context, 'No need to merge to itself, select a different payee');
            } else {
              // reparent Category
              Data().categories.reparentCategory(widget.categoryToMove, _categoryPicked);
              Navigator.pop(context);
            }
          },
          child: const Text('Append'),
        ),

        // Merge
        ElevatedButton(
          onPressed: () {
            if (_categoryPicked == widget.categoryToMove) {
              showSnackBar(context, 'No need to merge to itself, select a different category');
            } else {
              // move to Transaction to the picked category
              moveTransactionsToCategory(
                _transactions,
                _categoryPicked,
              );

              // we can now delete picked category
              widget.categoryToMove.stashValueBeforeEditing();
              Data().notifyMutationChanged(
                mutation: MutationType.deleted,
                moneyObject: widget.categoryToMove,
                fireNotification: false,
              );

              Data().recalculateBalances();
              Settings().rebuild();

              Navigator.pop(context);
            }
          },
          child: const Text('Merge'),
        ),
      ],
    );
  }

  Widget _buildLearning() {
    final from = widget.categoryToMove.name.value;
    final to = _categoryPicked.name.value;

    if (from == to) {
      return infoBox('Selection', 'Pick a different category then "$from".');
    }
    return Column(
      children: [
        infoBox('Append', 'Use this option to move "$from" as a child of category of "$to".'),
        gapLarge(),
        infoBox('Merge', 'Use this option to merge the transactions of "$from" to "$to".'),
      ],
    );
  }

  Widget infoBox(final String title, final String text) {
    return Box(
      title: title,
      child: Text(text),
    );
  }
}

void moveTransactionsToCategory(final List<Transaction> transactions, final Category moveToCategory) {
  for (final t in transactions) {
    t.stashValueBeforeEditing();
    t.categoryId.value = moveToCategory.uniqueId;

    Data().notifyMutationChanged(
      mutation: MutationType.changed,
      moneyObject: t,
      fireNotification: false,
    );
  }
}
