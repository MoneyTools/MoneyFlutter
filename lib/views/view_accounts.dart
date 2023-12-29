import 'package:flutter/material.dart';
import 'package:money/models/money_entity.dart';

import 'package:money/helpers.dart';
import 'package:money/models/accounts.dart';
import 'package:money/models/transactions.dart';
import 'package:money/widgets/caption_and_counter.dart';
import 'package:money/widgets/columns.dart';
import 'package:money/widgets/header.dart';
import 'package:money/widgets/widget_bar_chart.dart';
import 'package:money/widgets/widget_view.dart';
import 'package:money/views/view_transactions.dart';

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

    pivots.add(CaptionAndCounter(caption: 'Banks', small: true, vertical: true, value: getTotalBalanceOfAccounts(<AccountType>[AccountType.checking, AccountType.savings])));
    pivots.add(CaptionAndCounter(caption: 'Cards', small: true, vertical: true, value: getTotalBalanceOfAccounts(<AccountType>[AccountType.credit])));
    pivots.add(CaptionAndCounter(caption: 'Assets', small: true, vertical: true, value: getTotalBalanceOfAccounts(<AccountType>[AccountType.asset])));
    pivots.add(CaptionAndCounter(caption: 'All', small: true, vertical: true, value: getTotalBalanceOfAccounts(<AccountType>[])));
  }

  double getTotalBalanceOfAccounts(final List<AccountType> types) {
    double total = 0.0;
    Accounts.activeAccount(types).forEach((final Account x) => total += x.balance);
    return total;
  }

  @override
  getClassNamePlural() {
    return 'Accounts';
  }

  @override
  getClassNameSingular() {
    return 'Account';
  }

  @override
  getDescription() {
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
  getSubViewContentForChart(final List<num> indices) {
    final List<CategoryValue> list = <CategoryValue>[];
    for (final MoneyEntity item in getList()) {
      final Account account = item as Account;
      if (account.isActive()) {
        list.add(CategoryValue(account.name, account.balance));
      }
    }

    return WidgetBarChart(
      key: Key(indices.toString()),
      list: list,
      variableNameHorizontal: 'Account',
      variableNameVertical: 'Balance',
    );
  }

  @override
  getSubViewContentForTransactions(final List<int> indices) {
    final Account? account = getFirstElement<Account>(indices, list);
    if (account != null && account.id > -1) {
      return ViewTransactions(
        key: Key(account.id.toString()),
        filter: (final Transaction transaction) => filterByAccountId(transaction, account.id),
        preference: preferenceJustTableDatePayeeCategoryAmountBalance,
        startingBalance: account.openingBalance,
      );
    }
    return const Text('No account transactions');
  }

  bool filterByAccountId(final Transaction t, final num accountId) {
    return t.accountId == accountId;
  }

  @override
  ColumnDefinitions<Account> getColumnDefinitionsForTable() {
    return ColumnDefinitions<Account>(list: <ColumnDefinition<Account>>[
      ColumnDefinition<Account>(
        name: 'Name',
        type: ColumnType.text,
        align: TextAlign.left,
        value: (final int index) {
          return list[index].name;
        },
        sort: (final Account a, final Account b, final bool sortAscending) {
          return sortByString(
            a.name,
            b.name,
            sortAscending,
          );
        },
      ),
      ColumnDefinition<Account>(
        name: 'Type',
        type: ColumnType.text,
        align: TextAlign.center,
        value: (final int index) {
          return list[index].getTypeAsText();
        },
        sort: (final Account a, final Account b, final bool sortAscending) {
          return sortByString(
            a.getTypeAsText(),
            b.getTypeAsText(),
            sortAscending,
          );
        },
      ),
      ColumnDefinition<Account>(
        name: 'Count',
        type: ColumnType.numeric,
        align: TextAlign.right,
        value: (final int index) {
          return list[index].count;
        },
        sort: (final Account a, final Account b, final bool sortAscending) {
          return sortByValue(
            a.count,
            b.count,
            sortAscending,
          );
        },
      ),
      ColumnDefinition<Account>(
        name: 'Balance',
        type: ColumnType.amount,
        align: TextAlign.right,
        value: (final int index) {
          return list[index].balance;
        },
        sort: (final Account a, final Account b, final bool sortAscending) {
          return sortByValue(
            a.balance,
            b.balance,
            sortAscending,
          );
        },
      ),
    ]);
  }

  @override
  getDefaultSortColumn() {
    return 0; // Sort by name
  }

  @override
  List<Account> getList() {
    return Accounts.activeAccount(getSelectedAccountType());
  }

  List<AccountType> getSelectedAccountType() {
    if (_selectedPivot[0]) {
      return <AccountType>[AccountType.checking, AccountType.savings];
    }

    if (_selectedPivot[1]) {
      return <AccountType>[AccountType.credit];
    }

    if (_selectedPivot[2]) {
      return <AccountType>[AccountType.asset];
    }
    return <AccountType>[]; // all
  }

  Widget renderToggles() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: ToggleButtons(
          direction: Axis.horizontal,
          onPressed: (final int index) {
            setState(() {
              for (int i = 0; i < _selectedPivot.length; i++) {
                _selectedPivot[i] = i == index;
              }
              list = getList();
              selectedItems.clear();
            });
          },
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 100.0,
          ),
          isSelected: _selectedPivot,
          children: pivots,
        ));
  }
}
