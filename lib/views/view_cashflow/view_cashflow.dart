// ignore_for_file: unnecessary_this

import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/categories/category.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view.dart';
import 'package:money/views/view_cashflow/panel_recurring.dart';
import 'package:money/views/view_cashflow/panel_sankey.dart';
import 'package:money/views/view_header.dart';
import 'package:money/widgets/gaps.dart';
import 'package:money/widgets/sankey/sankey.dart';
import 'package:money/widgets/years_range_selector.dart';

class ViewCashFlow extends ViewWidget {
  const ViewCashFlow({super.key});

  @override
  State<ViewWidget> createState() => ViewCashFlowState();
}

enum ViewAs {
  sankey,
  recurring,
}

class ViewCashFlowState extends ViewWidgetState {
  ViewAs viewAs = ViewAs.sankey;
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
    switch (viewAs) {
      case ViewAs.sankey:
        return Container(
            color: getColorTheme(context).background, child: PanelSanKey(minYear: this.minYear, maxYear: this.maxYear));
      case ViewAs.recurring:
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
            _buildIncomeVsExpense(),
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
    return SegmentedButton<ViewAs>(
      style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
      segments: const <ButtonSegment<ViewAs>>[
        ButtonSegment<ViewAs>(
          value: ViewAs.sankey,
          label: Text('Sankey'),
        ),
        ButtonSegment<ViewAs>(
          value: ViewAs.recurring,
          label: Text('Recurring'),
        ),
      ],
      selected: <ViewAs>{viewAs},
      onSelectionChanged: (final Set<ViewAs> newSelection) {
        setState(() {
          viewAs = newSelection.first;
        });
      },
    );
  }

  Widget _buildIncomeVsExpense() {
    if (viewAs == ViewAs.sankey) {
      return const SizedBox();
    }

    return SegmentedButton<ViewRecurringAs>(
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
    );
  }
}
