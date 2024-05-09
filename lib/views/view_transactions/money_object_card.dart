import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/transactions/transactions.dart';
import 'package:money/widgets/box.dart';

class MoneyObjectCard extends StatelessWidget {
  final String title;
  final MoneyObject? moneyObject;
  final Function? onMergeWith;
  final Function? onEdit;
  final Function? onDelete;

  const MoneyObjectCard({
    super.key,
    required this.title,
    this.moneyObject,
    this.onEdit,
    this.onMergeWith,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    if (title.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: getTextTheme(context).headlineSmall,
              ),
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
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      onEdit?.call(
                        context,
                        moneyObject,
                      );
                    },
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        onDelete?.call(
                          context,
                          moneyObject,
                        );
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.copy_all),
                    onPressed: () {
                      copyToClipboardAndInformUser(context, moneyObject!.getPersistableJSon().toString());
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }

    if (moneyObject == null) {
      widgets.add(const Text('- not found -'));
    } else {
      widgets.addAll(
        moneyObject!.buildWidgets(onEdit: null, compact: true),
      );
    }

    return Box(
      color: getColorTheme(context).primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets,
        ),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final String title;
  final Transaction? transaction;

  const TransactionCard({
    super.key,
    required this.title,
    this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return MoneyObjectCard(
      title: title,
      moneyObject: transaction,
    );
  }
}
