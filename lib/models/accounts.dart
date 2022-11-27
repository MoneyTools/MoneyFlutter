import 'package:collection/collection.dart';
import 'package:money/models/transactions.dart';

import '../widgets/virtualTable.dart';

enum AccountType {
  savings,
  checking,
  moneyMarket,
  cash,
  credit,
  investment,
  retirement,
  _notUsed_7, // There is a hole here from deleted type which we can fill when we invent new types, but the types 8-10 have to keep those numbers or else we mess up the existing databases.
  asset, // Used for tracking Assets like "House, Car, Boat, Jewelry, this helps to make NetWorth more accurate
  categoryFund, // a pseudo account for managing category budgets
  loan,
  creditLine
}

enum AccountFlags { none, budgeted, closed, raxDeferred }

class Account {
  num id = -1;
  String name = "";
  int count = 0;
  double balance = 0.00;
  int flags = 0;
  AccountType type = AccountType.checking;

  Account(this.id, this.name);

  isClosed() {
    return (flags & AccountFlags.closed.index) != 0;
  }

  getTypeAsText() {
    switch (type) {
      case AccountType.savings:
        return "Savings";
      case AccountType.checking:
        return "Checking";
      case AccountType.moneyMarket:
        return "MoneyMarket";
      case AccountType.cash:
        return "Cash";
      case AccountType.credit:
        return "Credit";
      case AccountType.investment:
        return "Investment";
      case AccountType.retirement:
        return "Retirement";
      case AccountType.asset:
        return "Asset";
      case AccountType.categoryFund:
        return "CategoryFund";
      case AccountType.loan:
        return "Loan";
      case AccountType.creditLine:
        return "CreditLine";
      default:
        break;
    }

    return "other $type";
  }
}

class Accounts {
  num runningBalance = 0;

  static List<Account> list = [];

  static getOpenAccounts() {
    return list.where((a) => !a.isClosed()).toList();
  }

  static Account? get(accountId) {
    return list.firstWhereOrNull((item) => item.id == accountId);
  }

  static String getNameFromId(num id) {
    var account = get(id);
    if (account == null) {
      return id.toString();
    }
    return account.name;
  }

/*
0 = "Id"
1 = "AccountId"
2 = "OfxAccountId"
3 = "Name"
4 = "Description"
5 = "Type"
6 = "OpeningBalance"
7 = "Currency"
8 = "OnlineAccount"
9 = "WebSite"
10 = "ReconcileWarning"
11 = "LastSync"
12 = "SyncGuid"
13 = "Flags"
14 = "LastBalance"
15 = "CategoryIdForPrincipal"
16 = "CategoryIdForInterest"
 */
  load(rows) async {
    runningBalance = 0;

    for (var row in rows) {
      var id = num.parse(row["Id"].toString());
      var name = row["Name"].toString();
      var flags = int.parse(row["Flags"].toString());
      var type = int.parse(row["Type"].toString());

      var a = Account(id, name);
      a.flags = flags;
      a.type = AccountType.values[type];

      list.add(a);
    }
    return list;
  }

  loadDemoData() {
    List<String> names = ['BankOfAmerica', 'BECU', 'FirstTech', 'Fidelity', 'Bank of Japan', 'Trust Canada', 'ABC Corp', 'Royal Bank', 'Unicorn', 'God-Inc'];
    list = List<Account>.generate(10, (i) => Account(i, names[i]));
  }

  static onAllDataLoaded() {
    for (var item in list) {
      item.count = 0;
      item.balance = 0;
    }

    for (var t in Transactions.list) {
      var item = get(t.accountId);
      if (item != null) {
        item.count++;
        item.balance += t.amount;
      }
    }
  }
}
