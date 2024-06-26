// ignore_for_file: unnecessary_this

import 'package:flutter/material.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/widgets/pick_number.dart';
import 'package:money/app/core/widgets/sankey/sankey.dart';
import 'package:money/app/core/widgets/years_range_selector.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/date_range.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/categories/category.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/view.dart';
import 'package:money/app/modules/home/sub_views/view_cashflow/panel_sankey.dart';
import 'package:money/app/modules/home/sub_views/view_cashflow/recurring/panel_recurring.dart';
import 'package:money/app/modules/home/sub_views/view_header.dart';
import 'package:money/app/modules/home/sub_views/view_transactions/no_transactions.dart';

class ViewCashFlow extends ViewWidget {
  const ViewCashFlow({super.key});

  @override
  State<ViewWidget> createState() => ViewCashFlowState();
}

class ViewCashFlowState extends ViewWidgetState {
  ViewCashFlowState();
  late DateRange dateRangeTransactions;

  late int selectedYearStart;
  late int selectedYearEnd;

  List<Account> accountsOpened = Data().accounts.getOpenAccounts();
  double totalIncomes = 0.00;
  double totalExpenses = 0.00;
  double totalSavings = 0.00;
  double totalInvestments = 0.00;
  double totalNones = 0.00;
  double padding = 10.0;
  double totalHeight = 0.0;

  Map<Category, double> mapOfIncomes = <Category, double>{};
  Map<Category, double> mapOfExpenses = <Category, double>{};
  List<SanKeyEntry> sanKeyListOfIncomes = <SanKeyEntry>[];
  List<SanKeyEntry> sanKeyListOfExpenses = <SanKeyEntry>[];

  Debouncer debouncer = Debouncer();

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
            child: getView(),
          ),
        ),
      ],
    );
  }

  Widget getView() {
    if (Data().transactions.isEmpty) {
      return const NoTransaction();
    }

    switch (PreferenceController.to.cashflowViewAs.value) {
      case CashflowViewAs.sankey:
        return PanelSanKey(
          minYear: this.selectedYearStart,
          maxYear: this.selectedYearEnd,
        );
      case CashflowViewAs.recurringIncomes:
        return PanelRecurrings(
          dateRangeSearch: dateRangeTransactions,
          minYear: this.selectedYearStart,
          maxYear: this.selectedYearEnd,
          viewRecurringAs: PreferenceController.to.cashflowViewAs.value,
        );
      case CashflowViewAs.recurringExpenses:
        return PanelRecurrings(
          dateRangeSearch: dateRangeTransactions,
          minYear: this.selectedYearStart,
          maxYear: this.selectedYearEnd,
          viewRecurringAs: PreferenceController.to.cashflowViewAs.value,
        );
    }
  }

  Widget _buildHeaderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: SizeForPadding.medium,
          spacing: SizeForPadding.large,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cash Flow',
              style: getTextTheme(context).titleLarge,
              textAlign: TextAlign.start,
            ),
            _buildSelectView(),
            if (PreferenceController.to.cashflowViewAs.value != CashflowViewAs.sankey)
              NumberPicker(
                title: 'Occurrence',
                selectedNumber: PreferenceController.to.cashflowRecurringOccurrences.value,
                onChanged: (int value) {
                  PreferenceController.to.cashflowRecurringOccurrences.value = value;
                },
              ),
          ],
        ),
        if (!Data().transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: YearRangeSlider(
              minYear: dateRangeTransactions.min!.year,
              maxYear: dateRangeTransactions.max!.year,
              onChanged: (minYear, maxYear) {
                debouncer.run(() {
                  if (mounted) {
                    setState(() {
                      this.selectedYearStart = minYear;
                      this.selectedYearEnd = maxYear;
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
    return SegmentedButton<CashflowViewAs>(
      style: const ButtonStyle(
        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
      ),
      segments: const <ButtonSegment<CashflowViewAs>>[
        ButtonSegment<CashflowViewAs>(
          value: CashflowViewAs.sankey,
          label: Text('Sankey'),
        ),
        ButtonSegment<CashflowViewAs>(
          value: CashflowViewAs.recurringIncomes,
          label: Text('Incomes'),
        ),
        ButtonSegment<CashflowViewAs>(
          value: CashflowViewAs.recurringExpenses,
          label: Text('Expenses'),
        ),
      ],
      selected: <CashflowViewAs>{PreferenceController.to.cashflowViewAs.value},
      onSelectionChanged: (final Set<CashflowViewAs> newSelection) {
        setState(() {
          PreferenceController.to.cashflowViewAs.value = newSelection.first;
        });
      },
    );
  }
}
