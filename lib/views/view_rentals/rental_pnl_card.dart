import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/money_model.dart';
import 'package:money/views/view_rentals/rental_pnl.dart';
import 'package:money/widgets/money_widget.dart';
import 'package:money/widgets/box.dart';
import 'package:money/widgets/gaps.dart';

class RentalPnLCard extends StatelessWidget {
  final RentalPnL pnl;
  final String? customTitle;

  const RentalPnLCard({
    super.key,
    required this.pnl,
    this.customTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Box(
      color: getColorTheme(context).surface,
      width: 300,
      // height: 300,
      margin: 10,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                gap(30),
                Expanded(
                    child: Text(
                  customTitle == null ? pnl.date.year.toString() : customTitle!,
                  textAlign: TextAlign.center,
                )),
                IconButton(
                  onPressed: () {
                    copyToClipboardAndInformUser(context, pnl.toString());
                  },
                  iconSize: 13,
                  icon: const Icon(Icons.copy),
                ),
              ],
            ),
            captionAndAmount(context: context, caption: 'Income', amount: pnl.income),
            gapLarge(),
            captionAndAmount(context: context, caption: 'Expense', amount: pnl.expenses),
            gapMedium(),
            captionAndAmount(context: context, caption: '  Interest', amount: pnl.expenseInterest, small: true),
            captionAndAmount(context: context, caption: '  Maintenance', amount: pnl.expenseMaintenance, small: true),
            captionAndAmount(context: context, caption: '  Management', amount: pnl.expenseManagement, small: true),
            captionAndAmount(context: context, caption: '  Repairs', amount: pnl.expenseRepairs, small: true),
            captionAndAmount(context: context, caption: '  Taxes', amount: pnl.expenseTaxes, small: true),
            gapLarge(),
            captionAndAmount(context: context, caption: 'Profit', amount: pnl.profit),
            gapMedium(),
            distribution(context: context),
          ],
        ),
      ),
    );
  }

  Widget captionAndAmount({
    required final BuildContext context,
    required final String caption,
    required final double amount,
    bool small = false,
  }) {
    return Row(
      children: [
        Expanded(
            child: Text(caption, style: small ? getTextTheme(context).bodySmall : getTextTheme(context).bodyMedium)),
        MoneyWidget(
          amountModel: MoneyModel(
            amount: amount,
            iso4217: pnl.currency,
            showCurrency: false,
            autoColor: true,
          ),
        ),
      ],
    );
  }

  Widget distribution({
    required final BuildContext context,
  }) {
    List<Widget> widgets = [];

    pnl.distributions.forEach((name, percentage) {
      if (name.isNotEmpty) {
        widgets.add(captionAndAmount(
            context: context, caption: '  $name', amount: pnl.profit * (percentage / 100), small: true));
      }
    });

    return Column(
      children: widgets,
    );
  }
}
