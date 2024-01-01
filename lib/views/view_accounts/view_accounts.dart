import 'package:flutter/material.dart';
import 'package:money/models/money_entity.dart';

import 'package:money/helpers.dart';
import 'package:money/models/accounts.dart';
import 'package:money/models/transactions.dart';
import 'package:money/widgets/caption_and_counter.dart';
import 'package:money/widgets/columns.dart';

import 'package:money/widgets/header.dart';
import 'package:money/widgets/table_view/table_transactions.dart';
import 'package:money/widgets/widget_bar_chart.dart';
import 'package:money/widgets/widget_view.dart';

part 'view_accounts_columns.dart';

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

    pivots.add(CaptionAndCounter(
        caption: 'Banks',
        small: true,
        vertical: true,
        value: getTotalBalanceOfAccounts(<AccountType>[AccountType.checking, AccountType.savings])));
    pivots.add(CaptionAndCounter(
        caption: 'Cards',
        small: true,
        vertical: true,
        value: getTotalBalanceOfAccounts(<AccountType>[AccountType.credit])));
    pivots.add(CaptionAndCounter(
        caption: 'Assets',
        small: true,
        vertical: true,
        value: getTotalBalanceOfAccounts(<AccountType>[AccountType.asset])));
    pivots.add(CaptionAndCounter(
        caption: 'All', small: true, vertical: true, value: getTotalBalanceOfAccounts(<AccountType>[])));
  }

  @override
  String getClassNamePlural() {
    return 'Accounts';
  }

  @override
  String getClassNameSingular() {
    return 'Account';
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
  Widget getSubViewContentForChart(final List<num> indices) {
    final List<PairXY> list = <PairXY>[];
    for (final MoneyEntity item in getList()) {
      final Account account = item as Account;
      if (account.isActive()) {
        list.add(PairXY(account.name, account.balance));
      }
    }

    list.sort((final PairXY a, final PairXY b) => (b.yValue.abs() - a.yValue.abs()).toInt());

    return WidgetBarChart(
      key: Key(indices.toString()),
      list: list.take(10).toList(),
      variableNameHorizontal: 'Account',
      variableNameVertical: 'Balance',
    );
  }

  @override
  getSubViewContentForTransactions(final List<int> indices) {
    final Account? account = getFirstElement<Account>(indices, list);
    if (account != null && account.id > -1) {
      filter(final Transaction transaction) => filterByAccountId(transaction, account.id);

      final List<Transaction> listOfTransactionForThisAccount = getFilteredTransactions(filter);

      return TableTransactions(
        key: Key(account.id.toString()),
        columnsToInclude: const <String>[
          columnIdDate,
          columnIdPayee,
          columnIdCategory,
          columnIdAmount,
        ],
        getList: () => listOfTransactionForThisAccount,
      );
    }
    return const Text('No account transactions');
  }

  @override
  ColumnDefinitions<Account> getColumnDefinitionsForTable() {
    return _getColumnDefinitionsForTable();
  }

  @override
  getDefaultSortColumn() {
    return 0; // Sort by name
  }

  @override
  List<Account> getList() {
    return Accounts.activeAccount(getSelectedAccountType());
  }
}
