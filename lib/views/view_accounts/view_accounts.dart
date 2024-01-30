import 'package:flutter/material.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/settings.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/widgets/center_message.dart';
import 'package:money/widgets/three_part_label.dart';
import 'package:money/widgets/list_view/transactions/list_view_transactions.dart';
import 'package:money/widgets/chart.dart';
import 'package:money/views/view.dart';

part 'view_accounts_details_panels.dart';

part 'view_accounts_helpers.dart';

/// Main view for all Accounts
class ViewAccounts extends ViewWidget<Account> {
  const ViewAccounts({super.key});

  @override
  State<ViewWidget<Account>> createState() => ViewAccountsState();
}

class ViewAccountsState extends ViewWidgetState<Account> {
  final List<Widget> pivots = <Widget>[];
  final List<bool> _selectedPivot = <bool>[false, false, false, true];

  @override
  void initState() {
    super.initState();

    pivots.add(ThreePartLabel(
        text1: 'Banks',
        small: true,
        isVertical: true,
        text2: Currency.getCurrencyText(
            getTotalBalanceOfAccounts(<AccountType>[AccountType.checking, AccountType.savings]))));
    pivots.add(ThreePartLabel(
        text1: 'Cards',
        small: true,
        isVertical: true,
        text2: Currency.getCurrencyText(getTotalBalanceOfAccounts(<AccountType>[AccountType.credit]))));
    pivots.add(ThreePartLabel(
        text1: 'Assets',
        small: true,
        isVertical: true,
        text2: Currency.getCurrencyText(getTotalBalanceOfAccounts(<AccountType>[AccountType.asset]))));
    pivots.add(ThreePartLabel(
        text1: 'All',
        small: true,
        isVertical: true,
        text2: Currency.getCurrencyText(getTotalBalanceOfAccounts(<AccountType>[]))));
  }

  @override
  String getClassNameSingular() {
    return 'Account';
  }

  @override
  String getClassNamePlural() {
    return 'Accounts';
  }

  @override
  String getDescription() {
    return 'Your main assets.';
  }

  @override
  Widget buildHeader([final Widget? child]) {
    return super.buildHeader(renderToggles());
  }

  @override
  List<Account> getList() {
    return Data()
        .accounts
        .activeAccount(
          getSelectedAccountType(),
          isActive: Settings().includeClosedAccounts ? null : true,
        )
        .where((final Account instance) => isMatchingFilterText(instance))
        .toList();
  }

  @override
  Widget getPanelForChart(final List<int> indices) {
    return _getSubViewContentForChart(indices);
  }

  @override
  Widget getPanelForTransactions(final List<int> indices) {
    return _getSubViewContentForTransactions(indices);
  }
}
