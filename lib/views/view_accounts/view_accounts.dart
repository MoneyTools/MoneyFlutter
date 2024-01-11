import 'package:flutter/material.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/accounts/account.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_entity.dart';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/accounts/accounts.dart';
import 'package:money/models/settings.dart';
import 'package:money/models/transactions/transaction.dart';
import 'package:money/widgets/table_view/table_transactions_fields.dart';
import 'package:money/widgets/three_part_label.dart';

import 'package:money/widgets/header.dart';
import 'package:money/widgets/table_view/table_transactions.dart';
import 'package:money/widgets/chart.dart';
import 'package:money/views/view.dart';

part 'view_accounts_fields.dart';

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
        text2: getCurrencyText(getTotalBalanceOfAccounts(<AccountType>[AccountType.checking, AccountType.savings]))));
    pivots.add(ThreePartLabel(
        text1: 'Cards',
        small: true,
        isVertical: true,
        text2: getCurrencyText(getTotalBalanceOfAccounts(<AccountType>[AccountType.credit]))));
    pivots.add(ThreePartLabel(
        text1: 'Assets',
        small: true,
        isVertical: true,
        text2: getCurrencyText(getTotalBalanceOfAccounts(<AccountType>[AccountType.asset]))));
    pivots.add(ThreePartLabel(
        text1: 'All',
        small: true,
        isVertical: true,
        text2: getCurrencyText(getTotalBalanceOfAccounts(<AccountType>[]))));
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
  Widget getTitle() {
    return Column(children: <Widget>[
      Header(getClassNamePlural(), numValueOrDefault(list.length), getDescription()),
      renderToggles(),
    ]);
  }

  @override
  FieldDefinitions<Account> getFieldDefinitionsForTable() {
    return _getFieldDefinitionsForTable();
  }

  @override
  getDefaultSortColumn() {
    return Settings().viewAccountSortBy; // Sort by name
  }

  @override
  List<Account> getList() {
    return Accounts.activeAccount(
      getSelectedAccountType(),
      isActive: Settings().includeClosedAccounts ? null : true,
    );
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
