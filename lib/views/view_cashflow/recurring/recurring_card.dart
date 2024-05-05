import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/money_model.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_cashflow/recurring/recurring_payment.dart';
import 'package:money/widgets/distribution_bar.dart';
import 'package:money/widgets/gaps.dart';
import 'package:money/widgets/mini_timeline.dart';
import 'package:money/widgets/money_widget.dart';

class RecurringCard extends StatelessWidget {
  final RecurringPayment payment;
  final List<Distribution> listForDistributionBar;
  final List<double> occurrences;

  const RecurringCard({
    super.key,
    required this.payment,
    required this.listForDistributionBar,
    required this.occurrences,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = getTextTheme(context);

    return Card(
      color: getColorTheme(context).background,
      elevation: 1,
      child: SizedBox(
        width: 400,
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(13.0),
            child: Column(
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
                          IntrinsicWidth(child: MoneyWidget(amountModel: MoneyModel(amount: payment.total))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            '${payment.frequency} occurrences, averaging each ',
                            style: textTheme.bodyMedium,
                          ),
                          MoneyWidget(amountModel: MoneyModel(amount: payment.total / payment.frequency)),
                        ],
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
                gapLarge(),
                Container(
                  height: 40,
                  margin: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                  child: HorizontalTimelineGraph(
                    values: occurrences,
                    color: getColorTheme(context).primary,
                  ),
                ),
                gapLarge(),
                Expanded(child: DistributionBar(segments: listForDistributionBar)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
