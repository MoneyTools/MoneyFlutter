import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/widgets/box.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/data/models/money_objects/money_object.dart';
import 'package:money/app/data/models/money_objects/transactions/transactions.dart';

class MoneyObjectCard extends StatelessWidget {
  const MoneyObjectCard({
    required this.title,
    super.key,
    this.moneyObject,
    this.onEdit,
    this.onMergeWith,
    this.onDelete,
  });
  final String title;
  final MoneyObject? moneyObject;
  final Function? onMergeWith;
  final Function? onEdit;
  final Function? onDelete;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    // Header
    if (title.isNotEmpty) {
      widgets.add(_buildCardHeader(context));
    }

    // Content
    if (moneyObject == null) {
      widgets.add(const Text('- not found -'));
    } else {
      widgets.add(gapLarge());
      widgets.addAll(
        moneyObject!.buildListOfNamesValuesWidgets(onEdit: null, compact: true),
      );
    }

    return Box(
      color: getColorTheme(context).primaryContainer,
      // padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  /// Header Object [Name, Id, Actions]
  Widget _buildCardHeader(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title
        Text(
          title,
          style: getTextTheme(context).headlineSmall,
        ),
        // Unique Id of the Object
        _buildMoneyObjectId(),

        // Header Action buttons
        Row(
          children: [
            if (onMergeWith != null)
              IconButton(
                icon: const Icon(Icons.merge),
                onPressed: () {
                  onMergeWith?.call(
                    context,
                    moneyObject,
                  );
                },
              ),
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  onEdit?.call(
                    context,
                    [moneyObject!],
                  );
                },
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  onDelete?.call(
                    context,
                    [moneyObject!],
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.copy_all),
              onPressed: () {
                copyToClipboardAndInformUser(
                  context,
                  moneyObject!.getPersistableJSon().toString(),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoneyObjectId() {
    if (kDebugMode) {
      return Opacity(
        opacity: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: SelectableText('ID:${moneyObject!.uniqueId}'),
        ),
      );
    }
    return const SizedBox();
  }
}

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    required this.title,
    super.key,
    this.transaction,
  });
  final String title;
  final Transaction? transaction;

  @override
  Widget build(BuildContext context) {
    return MoneyObjectCard(
      title: title,
      moneyObject: transaction,
    );
  }
}
