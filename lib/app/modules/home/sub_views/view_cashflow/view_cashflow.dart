// ignore_for_file: unnecessary_this

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/ranges.dart';
import 'package:money/app/core/widgets/center_message.dart';
import 'package:money/app/core/widgets/my_segment.dart';
import 'package:money/app/core/widgets/pick_number.dart';
import 'package:money/app/core/widgets/sankey/sankey.dart';
import 'package:money/app/core/widgets/years_range_selector.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/categories/category.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/view.dart';
import 'package:money/app/modules/home/sub_views/view_cashflow/net_worth_chart.dart';
import 'package:money/app/modules/home/sub_views/view_cashflow/panel_sankey.dart';
import 'package:money/app/modules/home/sub_views/view_cashflow/recurring/panel_recurring.dart';
import 'package:money/app/modules/home/sub_views/view_header.dart';

class ViewCashFlow extends ViewWidget {
  const ViewCashFlow({super.key});

  @override
  State<ViewWidget> createState() => ViewCashFlowState();
}

class ViewCashFlowState extends ViewWidgetState {
  ViewCashFlowState();

  List<Account> accountsOpened = Data().accounts.getOpenAccounts();
  late DateRange dateRangeTransactions;
  Map<Category, double> mapOfExpenses = <Category, double>{};
  Map<Category, double> mapOfIncomes = <Category, double>{};
  double padding = 10.0;
  List<SanKeyEntry> sanKeyListOfExpenses = <SanKeyEntry>[];
  List<SanKeyEntry> sanKeyListOfIncomes = <SanKeyEntry>[];
  late int selectedYearEnd;
  late int selectedYearStart;
  double totalExpenses = 0.00;
  double totalHeight = 0.0;
  double totalIncomes = 0.00;
  double totalInvestments = 0.00;
  double totalNones = 0.00;
  double totalSavings = 0.00;

  final Debouncer _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    dateRangeTransactions = DateRange.fromStarEndYears(
      Data().transactions.dateRangeActiveAccount.min?.year ?? DateTime.now().year,
      Data().transactions.dateRangeActiveAccount.max?.year ?? DateTime.now().year,
    );

    this.selectedYearStart = dateRangeTransactions.min!.year;
    this.selectedYearEnd = dateRangeTransactions.max!.year;
  }

  @override
  Widget build(final BuildContext context) {
    return Obx(
      () {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header
            ViewHeader.buildViewHeaderContainer(context, _buildHeaderContent()),
            // View
            Expanded(
              child: Container(
                key: Key(
                  PreferenceController.to.cashflowViewAs.value.toString() +
                      selectedYearStart.toString() +
                      selectedYearEnd.toString(),
                ),
                // rebuild if the date changes
                color: getColorTheme(context).surface,
                child: _buildView(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: SizeForPadding.medium,
          spacing: SizeForPadding.large,
          children: [
            Text(
              'Cash Flow',
              style: getTextTheme(context).titleLarge,
              textAlign: TextAlign.start,
            ),

            //
            // Select a view
            //
            _buildSelectView(),

            //
            // Optional settings for Recurrence
            //
            if ([CashflowViewAs.recurringExpenses, CashflowViewAs.recurringIncomes]
                .contains(PreferenceController.to.cashflowViewAs.value))
              NumberPicker(
                title: 'Occurrence',
                selectedNumber: PreferenceController.to.cashflowRecurringOccurrences.value,
                onChanged: (int value) {
                  PreferenceController.to.cashflowRecurringOccurrences.value = value;
                },
              ),

            //
            // Optional settings for NetWorth
            //
            if (CashflowViewAs.netWorthOverTime == PreferenceController.to.cashflowViewAs.value)
              NumberPicker(
                title: 'Event Tolerances',
                selectedNumber: PreferenceController.to.netWorthEventThreshold.value,
                onChanged: (int value) {
                  PreferenceController.to.netWorthEventThreshold.value = value;
                },
              ),
          ],
        ),
        if (!Data().transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: YearRangeSlider(
              yearRange: NumRange(min: dateRangeTransactions.min!.year, max: dateRangeTransactions.max!.year),
              initialRange: NumRange(min: dateRangeTransactions.min!.year, max: dateRangeTransactions.max!.year),
              onChanged: (final NumRange updateRange) {
                _debouncer.run(() {
                  if (mounted) {
                    setState(() {
                      this.selectedYearStart = updateRange.min.toInt();
                      this.selectedYearEnd = updateRange.max.toInt();
                    });
                  }
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSelectView() {
    return mySegmentSelector(
      segments: [
        ButtonSegment<int>(
          value: CashflowViewAs.sankey.index,
          label: const Text('Sankey'),
        ),
        ButtonSegment<int>(
          value: CashflowViewAs.netWorthOverTime.index,
          label: const Text('NetWorth'),
        ),
        ButtonSegment<int>(
          value: CashflowViewAs.recurringIncomes.index,
          label: const Text('Incomes'),
        ),
        ButtonSegment<int>(
          value: CashflowViewAs.recurringExpenses.index,
          label: const Text('Expenses'),
        ),
      ],
      selectedId: PreferenceController.to.cashflowViewAs.value.index,
      onSelectionChanged: (final int newSelection) {
        PreferenceController.to.cashflowViewAs.value = CashflowViewAs.values[newSelection];
      },
    );
  }

  Widget _buildView() {
    if (Data().transactions.isEmpty) {
      return CenterMessage.noTransaction();
    }

    switch (PreferenceController.to.cashflowViewAs.value) {
      case CashflowViewAs.sankey:
        return PanelSanKey(
          minYear: this.selectedYearStart,
          maxYear: this.selectedYearEnd,
        );

      case CashflowViewAs.netWorthOverTime:
        return NetWorthChart(
          minYear: this.selectedYearStart,
          maxYear: this.selectedYearEnd,
        );

      case CashflowViewAs.recurringIncomes:
        return PanelRecurring(
          dateRangeSearch: dateRangeTransactions,
          minYear: this.selectedYearStart,
          maxYear: this.selectedYearEnd,
          viewRecurringAs: PreferenceController.to.cashflowViewAs.value,
        );

      case CashflowViewAs.recurringExpenses:
        return PanelRecurring(
          dateRangeSearch: dateRangeTransactions,
          minYear: this.selectedYearStart,
          maxYear: this.selectedYearEnd,
          viewRecurringAs: PreferenceController.to.cashflowViewAs.value,
        );
    }
  }
}
