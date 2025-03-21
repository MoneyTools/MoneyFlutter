import 'package:flutter/material.dart';
import 'package:money/core/helpers/misc_helpers.dart';
import 'package:money/core/widgets/box.dart';
import 'package:money/core/widgets/gaps.dart';
import 'package:money/core/widgets/label_and_amount.dart';
import 'package:money/data/models/money_model.dart';
import 'package:money/views/home/sub_views/view_rentals/rental_pnl.dart';

class RentalPnLCard extends StatelessWidget {
  const RentalPnLCard({required this.pnl, super.key, this.customTitle});

  final String? customTitle;
  final RentalPnL pnl;

  @override
  Widget build(BuildContext context) {
    return BoxWithScrollingContent(
      children: <Widget>[
        Row(
          children: <Widget>[
            gap(30),
            Expanded(
              child: Text(
                customTitle == null ? pnl.date.year.toString() : customTitle!,
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              key: const Key('key_card_copy_to_clipboard'),
              onPressed: () {
                copyToClipboardAndInformUser(context, pnl.toString());
              },
              iconSize: SizeForIcon.small,
              icon: const Icon(Icons.copy),
            ),
          ],
        ),
        LabelAndAmount(
          caption: 'Income',
          amount: pnl.income,
          currencyIso4217: pnl.currency,
        ),
        gapLarge(),
        LabelAndAmount(
          caption: 'Expense',
          amount: pnl.expenses,
          currencyIso4217: pnl.currency,
        ),
        gapMedium(),
        LabelAndAmount(
          caption: '  Interest',
          amount: pnl.expenseInterest,
          currencyIso4217: pnl.currency,
          small: true,
        ),
        LabelAndAmount(
          caption: '  Maintenance',
          amount: pnl.expenseMaintenance,
          currencyIso4217: pnl.currency,
          small: true,
        ),
        LabelAndAmount(
          caption: '  Management',
          amount: pnl.expenseManagement,
          currencyIso4217: pnl.currency,
          small: true,
        ),
        LabelAndAmount(
          caption: '  Repairs',
          amount: pnl.expenseRepairs,
          currencyIso4217: pnl.currency,
          small: true,
        ),
        LabelAndAmount(
          caption: '  Taxes',
          amount: pnl.expenseTaxes,
          currencyIso4217: pnl.currency,
          small: true,
        ),
        gapLarge(),
        LabelAndAmount(
          caption: 'Profit',
          amount: pnl.profit,
          currencyIso4217: pnl.currency,
        ),
        gapMedium(),
        distribution(context: context),
      ],
    );
  }

  Widget distribution({required final BuildContext context}) {
    final List<Widget> widgets = <Widget>[];

    pnl.distributions.forEach((String name, double percentage) {
      if (name.isNotEmpty) {
        widgets.add(
          LabelAndAmount(
            caption: '  $name',
            amount: pnl.profit * (percentage / 100),
            currencyIso4217: pnl.currency,
            small: true,
          ),
        );
      }
    });

    return Column(children: widgets);
  }
}
