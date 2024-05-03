import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/money_model.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_cashflow/recurring/recurring_payment.dart';
import 'package:money/widgets/distribution_bar.dart';
import 'package:money/widgets/money_widget.dart';

class RecurringCard extends StatelessWidget {
  final RecurringPayment payment;
  final List<Distribution> listForDistributionBar;

  const RecurringCard({
    super.key,
    required this.payment,
    required this.listForDistributionBar,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = getTextTheme(context);

    return Card(
      color: getColorTheme(context).background,
      elevation: 1,
      child: SizedBox(
        width: 400,
        height: 300,
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: SelectableText(
                            Data().payees.getNameFromId(payment.payeeId),
                            maxLines: 1,
                            style: textTheme.titleMedium,
                          ),
                        ),
                        Expanded(child: MoneyWidget(amountModel: MoneyModel(amount: payment.total))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${payment.frequency} occurrences',
                      style: textTheme.bodyMedium,
                    ),
                    Row(
                      children: [
                        const Text('Average total per year '),
                        MoneyWidget(amountModel: MoneyModel(amount: payment.total / payment.numberOfYears)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(child: DistributionBar(segments: listForDistributionBar)),
            ],
          ),
        ),
      ),
    );
  }
}
