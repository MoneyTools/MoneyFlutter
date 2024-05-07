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

  final bool forIncomeTransaction;

  const RecurringCard({
    super.key,
    required this.index,
    required this.payment,
    required this.forIncomeTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: getColorTheme(context).background,
      margin: const EdgeInsets.only(bottom: 21),
      elevation: 4,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(13.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(context),

            // break down the numbers
            _buildDetailAverages(context),

            // Category Distributions
            IntrinsicHeight(
              child: DistributionBar(
                title: 'Categories',
                segments: payment.categoryDistribution,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(final BuildContext context) {
    TextTheme textTheme = getTextTheme(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Opacity(opacity: 0.5, child: Text('#$index ')),
        Expanded(
          child: SelectableText(
            Data().payees.getNameFromId(payment.payeeId),
            maxLines: 1,
            style: textTheme.titleMedium,
          ),
        ),
        gapLarge(),
        MoneyWidget(amountModel: MoneyModel(amount: payment.total)),
      ],
    );
  }

  Widget _buildDetailAverages(final BuildContext context) {
    return Box(
      title: 'Averages from ${payment.dateRangeFound.toStringYears()}',
      padding: 21,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 55,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: HorizontalTimelineGraph(
              values: payment.averagePerMonths,
              color: getColorTheme(context).primary,
            ),
          ),

          _buildTextAmountRow(context, 'Per Transaction (${payment.frequency})', payment.total / payment.frequency),
          // Average per yearS
          _buildTextAmountRow(context, 'Year', payment.total / (payment.dateRangeFound.durationInYears)),
          // Average per month
          _buildTextAmountRow(context, 'Month', payment.total / (payment.dateRangeFound.durationInMonths)),
          // Average per day
          _buildTextAmountRow(context, 'Day', payment.total / (payment.dateRangeFound.durationInDays)),
        ],
      ),
    );
  }
}

Widget _buildTextAmountRow(final BuildContext context, final String title, final double amount) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: getTextTheme(context).labelMedium),
      MoneyWidget(amountModel: MoneyModel(amount: amount)),
    ],
  );
}
