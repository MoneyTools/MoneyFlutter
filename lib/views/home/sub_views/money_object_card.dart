import 'package:flutter/material.dart';
import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/helpers/string_helper.dart';
import 'package:money/core/widgets/box.dart';
import 'package:money/core/widgets/center_message.dart';
import 'package:money/core/widgets/gaps.dart';
import 'package:money/data/models/money_objects/money_object.dart';
import 'package:money/data/models/money_objects/transactions/transactions.dart';

class MoneyObjectCard extends StatelessWidget {
  const MoneyObjectCard({
    required this.title,
    super.key,
    this.moneyObject,
    this.onEdit,
    this.onMergeWith,
    this.onDelete,
  });

  final MoneyObject? moneyObject;
  final Function? onDelete;
  final Function? onEdit;
  final Function? onMergeWith;
  final String title;

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];

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

Widget buildAdaptiveBox({
  required final BuildContext context,
  required final String title,
  required final int count,
  required final Widget content,
  final Widget? footer,
}) {
  return Box(
    height: 300,
    color: getColorTheme(context).primaryContainer,
    header: buildHeaderTitleAndCounter(context, title, count == 0 ? '' : getIntAsText(count)),
    footer: footer,
    padding: SizeForPadding.huge,
    child: count == 0 ? CenterMessage(message: 'No $title found') : content,
  );
}
