import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/transactions/transactions.dart';
import 'package:money/widgets/box.dart';

class MoneyObjectCard extends StatelessWidget {
  final String title;
  final MoneyObject? moneyObject;

  const MoneyObjectCard({
    super.key,
    required this.title,
    this.moneyObject,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    if (title.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            title,
            style: getTextTheme(context).headlineSmall,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
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
