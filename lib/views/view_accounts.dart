import 'package:flutter/material.dart';

import '../helpers.dart';
import '../models/accounts.dart';
import '../models/transactions.dart';
import '../widgets/columns.dart';
import '../widgets/widget_bar_chart.dart';
import '../widgets/widget_view.dart';
import 'view_transactions.dart';

class ViewAccounts extends ViewWidget {
  const ViewAccounts({super.key});

  @override
  State<ViewWidget> createState() => ViewAccountsState();
}

class ViewAccountsState extends ViewWidgetState {
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
    return Accounts.getOpenAccounts();
  }
}
