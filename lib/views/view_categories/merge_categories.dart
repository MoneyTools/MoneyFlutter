import 'package:flutter/material.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/transactions/transactions.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_categories/picker_category.dart';
import 'package:money/widgets/box.dart';
import 'package:money/widgets/gaps.dart';
import 'package:money/widgets/info_banner.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 100, child: Text('From category')),
            Expanded(
              child: Box(child: Text(widget.categoryToMove.name.value)),
            ),
          ],
        ),
        gapLarge(),
        gapLarge(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 100, child: Text('To category')),
            Expanded(
              child: Box(
                child: pickerCategory(
                  itemSelected: widget.categoryToMove,
                  onSelected: (final Category? newSelection) {
                    setState(() {
                      _categoryPicked = newSelection!;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildActionPanel(),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildActionPanel() {
    final from = widget.categoryToMove.name.value;
    final to = _categoryPicked.name.value;

    if (from == to) {
      return Center(child: InfoBanner.warning('Pick a different category then "$from".'));
    }

    return Center(
      child: Wrap(
        spacing: SizeForPadding.large,
        runSpacing: SizeForPadding.large,
        children: [
          // Append
          _buildActionOffering(
            'Use this option to move "$from" as a child of category of "$to".',
            OutlinedButton(
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
          ),
          gapLarge(),
          // Merge
          _buildActionOffering(
            'Use this option to merge the transactions of "$from" in to "$to".',
            OutlinedButton(
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

                  Data().updateAll();

                  Navigator.pop(context);
                }
              },
              child: const Text('Merge'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionOffering(final String text, Widget action) {
    return SizedBox(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: action,
          ),
          gapMedium(),
          Text(text),
          gapMedium(),
        ],
      ),
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
