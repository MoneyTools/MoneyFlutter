import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/money_model.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_cashflow/recurring/recurring_payment.dart';
import 'package:money/widgets/box.dart';
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
                // Header
                _buildHeader(context),

                // total over time
                _buildExplanations(context),

                // Timeline 1 to 12 months
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                  child: HorizontalTimelineGraph(
                    values: occurrences,
                    color: getColorTheme(context).primary,
                  ),
                ),
                gapLarge(),

                // Category Distributions
                Expanded(child: DistributionBar(segments: listForDistributionBar)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(final BuildContext context) {
    TextTheme textTheme = getTextTheme(context);
    return Row(
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
    );
  }

  Widget _buildExplanations(final BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Range from ${payment.dateRange.toStringYears()} '),
        _buildDetailAverages(context),
      ],
    );
  }

  Widget _buildDetailAverages(final BuildContext context) {
    TextTheme textTheme = getTextTheme(context);
    return Box(
      margin: 8,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${payment.frequency} occurrences, averaging each ',
                style: textTheme.bodyMedium,
              ),
              MoneyWidget(amountModel: MoneyModel(amount: payment.total / payment.frequency)),
            ],
          ),
          // average per year
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Average per yearS
              _buildTextAmountBox(context, 'Year', payment.total / (payment.dateRange.durationInYears)),
              // Average per month
              _buildTextAmountBox(context, 'Month', payment.total / (payment.dateRange.durationInMonths)),
              // Average per day
              _buildTextAmountBox(context, 'Day', payment.total / (payment.dateRange.durationInDays)),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildTextAmountBox(final BuildContext context, final String title, final double amount) {
  return Box(
      margin: 4,
      width: 140,
      child: Column(
        children: [
          Text(title, style: getTextTheme(context).titleMedium),
          MoneyWidget(amountModel: MoneyModel(amount: amount)),
        ],
      ));
}
