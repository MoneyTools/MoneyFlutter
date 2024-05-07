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
  final int index;
  final RecurringPayment payment;
  final List<Distribution> listForDistributionBar;
  final List<double> occurrences;

  const RecurringCard({
    super.key,
    required this.index,
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
              children: [
                // Header
                _buildHeader(context),

                gapLarge(),

                // break down the numbers
                _buildDetailAverages(context),

                gapLarge(),

                // Category Distributions
                Expanded(child: DistributionBar(title: 'Categories', segments: listForDistributionBar)),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Opacity(opacity: 0.5, child: Text('#$index ')),
        Expanded(
          flex: 1,
          child: SelectableText(
            Data().payees.getNameFromId(payment.payeeId),
            maxLines: 1,
            style: textTheme.titleMedium,
          ),
        ),
        Expanded(child: IntrinsicWidth(child: Text(payment.dateRange.toStringYears()))),
        IntrinsicWidth(child: MoneyWidget(amountModel: MoneyModel(amount: payment.total))),
      ],
    );
  }

  Widget _buildDetailAverages(final BuildContext context) {
    return Box(
      title: 'Averages',
      padding: 13,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 55,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: HorizontalTimelineGraph(
              values: occurrences,
              color: getColorTheme(context).primary,
            ),
          ),

          _buildTextAmountBox(context, 'Per Transaction (${payment.frequency})', payment.total / payment.frequency),
          // Average per yearS
          _buildTextAmountBox(context, 'Year', payment.total / (payment.dateRange.durationInYears)),
          // Average per month
          _buildTextAmountBox(context, 'Month', payment.total / (payment.dateRange.durationInMonths)),
          // Average per day
          _buildTextAmountBox(context, 'Day', payment.total / (payment.dateRange.durationInDays)),
        ],
      ),
    );
  }
}

Widget _buildTextAmountBox(final BuildContext context, final String title, final double amount) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: getTextTheme(context).titleMedium),
      MoneyWidget(amountModel: MoneyModel(amount: amount)),
    ],
  );
}
