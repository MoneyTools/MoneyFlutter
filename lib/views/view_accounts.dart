import 'package:flutter/material.dart';

import '../helpers.dart';
import '../models/accounts.dart';
import '../models/transactions.dart';
import '../widgets/caption_and_counter.dart';
import '../widgets/columns.dart';
import '../widgets/header.dart';
import '../widgets/widget_bar_chart.dart';
import '../widgets/widget_view.dart';
import 'view_transactions.dart';

class ViewAccounts extends ViewWidget {
  const ViewAccounts({super.key});

  @override
  State<ViewWidget> createState() => ViewAccountsState();
}

class ViewAccountsState extends ViewWidgetState {
  final List<Widget> pivots = [];
  final List<bool> _selectedPivot = <bool>[false, false, false, true];

  @override
  void initState() {
    super.initState();

    pivots.add(CaptionAndCounter(caption: "Banks", small: true, vertical: true, value: getTotalBalanceOfAccounts([AccountType.checking, AccountType.savings])));
    pivots.add(CaptionAndCounter(caption: "Cards", small: true, vertical: true, value: getTotalBalanceOfAccounts([AccountType.credit])));
    pivots.add(CaptionAndCounter(caption: "Assets", small: true, vertical: true, value: getTotalBalanceOfAccounts([AccountType.asset])));
    pivots.add(CaptionAndCounter(caption: "All", small: true, vertical: true, value: getTotalBalanceOfAccounts([])));
  }

  double getTotalBalanceOfAccounts(List<AccountType> types) {
    var total = 0.0;
    Accounts.activeAccount(types).forEach((x) => total += (x as Account).balance);
    return total;
  }

  @override
  getClassNamePlural() {
    return "Accounts";
  }

  @override
  getClassNameSingular() {
    return "Account";
  }

  @override
  getDescription() {
    return "Your main assets.";
  }

  @override
  Widget getTitle() {
    return Column(children: [
      Header(getClassNamePlural(), numValueOrDefault(list.length), getDescription()),
      renderToggles(),
    ]);
  }

  @override
  getSubViewContentForChart(List<int> indices) {
    List<CategoryValue> list = [];
    for (var account in getList()) {
      if (account.isActiveBankAccount()) {
        list.add(CategoryValue(account.name, account.balance));
      }
    }

    return WidgetBarChart(
      key: Key(indices.toString()),
      list: list,
      variableNameHorizontal: "Account",
      variableNameVertical: "Balance",
    );
  }

  @override
  getSubViewContentForTransactions(List<int> indices) {
    var account = getFirstElement<Account>(indices, list);
    if (account != null && account.id > -1) {
      return ViewTransactions(
        key: Key(account.id.toString()),
        filter: (t) => filterByAccountId(t, account.id),
        preference: preferenceJustTableDatePayeeCategoryAmountBalance,
        startingBalance: account.openingBalance,
      );
    }
    return const Text("No account transactions");
  }

  bool filterByAccountId(Transaction t, accountId) {
    return t.accountId == accountId;
  }

  @override
  ColumnDefinitions getColumnDefinitionsForTable() {
    return ColumnDefinitions([
      ColumnDefinition(
        "Name",
        ColumnType.text,
        TextAlign.left,
        (index) {
          return list[index].name;
        },
        (a, b, sortAscending) {
          return sortByString(a.name, b.name, sortAscending);
        },
      ),
      ColumnDefinition(
        "Type",
        ColumnType.text,
        TextAlign.center,
        (index) {
          return list[index].getTypeAsText();
        },
        (a, b, sortAscending) {
          return sortByString(a.getTypeAsText(), b.getTypeAsText(), sortAscending);
        },
      ),
      ColumnDefinition(
        "Count",
        ColumnType.numeric,
        TextAlign.right,
        (index) {
          return list[index].count;
        },
        (a, b, sortAscending) {
          return sortByValue(a.count, b.count, sortAscending);
        },
      ),
      ColumnDefinition(
        "Balance",
        ColumnType.amount,
        TextAlign.right,
        (index) {
          return list[index].balance;
        },
        (a, b, sortAscending) {
          return sortByValue(a.balance, b.balance, sortAscending);
        },
      ),
    ]);
  }

  @override
  getDefaultSortColumn() {
    return 0; // Sort by name
  }

  @override
  getList() {
    return Accounts.activeAccount(getSelectedAccountType());
  }

  List<AccountType> getSelectedAccountType() {
    if (_selectedPivot[0]) {
      return [AccountType.checking, AccountType.savings];
    }

    if (_selectedPivot[1]) {
      return [AccountType.credit];
    }

    if (_selectedPivot[2]) {
      return [AccountType.asset];
    }
    return []; // all
  }

  renderToggles() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: ToggleButtons(
          direction: Axis.horizontal,
          onPressed: (int index) {
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
