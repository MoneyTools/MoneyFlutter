// ignore_for_file: unnecessary_this

import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/categories/category.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view.dart';
import 'package:money/views/view_cashflow/panel_sankey.dart';
import 'package:money/views/view_cashflow/recurring/panel_recurring.dart';
import 'package:money/views/view_header.dart';
import 'package:money/widgets/gaps.dart';
import 'package:money/widgets/pick_number.dart';
import 'package:money/widgets/sankey/sankey.dart';
import 'package:money/widgets/years_range_selector.dart';

class ViewCashFlow extends ViewWidget {
  const ViewCashFlow({super.key});

  @override
  State<ViewWidget> createState() => ViewCashFlowState();
}

class ViewCashFlowState extends ViewWidgetState {
  ViewRecurringAs viewRecurringAs = ViewRecurringAs.expenses;

  late int minYear;
  late int maxYear;

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

  ViewCashFlowState();

  @override
  void initState() {
    super.initState();
    this.minYear = Data().transactions.dateRangeActiveAccount.min?.year ?? 2020;
    this.maxYear = Data().transactions.dateRangeActiveAccount.max?.year ?? 2020;
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ViewHeader(
          title: 'Cash Flow',
          count: totalIncomes + totalExpenses,
          description: 'See where assets are allocated.',
          child: getViewSelector(),
        ),
        Expanded(
          child: getView(),
        ),
      ],
    );
  }

  Widget getView() {
    switch (Settings().cashflowViewAs) {
      case CashflowViewAs.sankey:
        return Container(
            color: getColorTheme(context).background, child: PanelSanKey(minYear: this.minYear, maxYear: this.maxYear));
      case CashflowViewAs.recurring:
        return PanelRecurrings(
          minYear: this.minYear,
          maxYear: this.maxYear,
          viewRecurringAs: viewRecurringAs,
        );
    }
  }

  Widget getViewSelector() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSelectView(),
            gapLarge(),
            _buildRecurringSettings(),
          ],
        ),
        YearRangeSlider(
          minYear: Data().transactions.dateRangeActiveAccount.min!.year,
          maxYear: Data().transactions.dateRangeActiveAccount.max!.year,
          onChanged: (minYear, maxYear) {
            debouncer.run(() {
              setState(() {
                this.minYear = minYear;
                this.maxYear = maxYear;
              });
            });
          },
        ),
      ],
    );
  }

  Widget _buildSelectView() {
    return SegmentedButton<CashflowViewAs>(
      style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
      segments: const <ButtonSegment<CashflowViewAs>>[
        ButtonSegment<CashflowViewAs>(
          value: CashflowViewAs.sankey,
          label: Text('Sankey'),
        ),
        ButtonSegment<CashflowViewAs>(
          value: CashflowViewAs.recurring,
          label: Text('Recurring'),
        ),
      ],
      selected: <CashflowViewAs>{Settings().cashflowViewAs},
      onSelectionChanged: (final Set<CashflowViewAs> newSelection) {
        setState(() {
          Settings().cashflowViewAs = newSelection.first;
          Settings().store();
        });
      },
    );
  }

  Widget _buildRecurringSettings() {
    if (Settings().cashflowViewAs == CashflowViewAs.sankey) {
      return const SizedBox();
    }

    return Row(
      children: [
        SegmentedButton<ViewRecurringAs>(
          style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
          segments: const <ButtonSegment<ViewRecurringAs>>[
            ButtonSegment<ViewRecurringAs>(
              value: ViewRecurringAs.incomes,
              label: Text('Incomes'),
            ),
            ButtonSegment<ViewRecurringAs>(
              value: ViewRecurringAs.expenses,
              label: Text('Expenses'),
            ),
          ],
          selected: <ViewRecurringAs>{viewRecurringAs},
          onSelectionChanged: (final Set<ViewRecurringAs> newSelection) {
            setState(() {
              viewRecurringAs = newSelection.first;
            });
          },
        ),
        gapMedium(),
        NumberPicker(
          title: 'Occurrence',
          selectedNumber: Settings().cashflowRecurringOccurrences,
          onChanged: (int value) {
            Settings().cashflowRecurringOccurrences = value;
            Settings().store();
          },
        ),
      ],
    );
  }
}
