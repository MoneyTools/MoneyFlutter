import 'package:money/models/transactions.dart';

import 'money_entity.dart';

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

class Account extends MoneyEntity {
  int count = 0;
  double balance = 0.00;
  int flags = 0;
  AccountType type = AccountType.checking;

  Account(id, name) : super(id, name) {
    //
  }

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
  static MoneyObjects moneyObjects = MoneyObjects();

  static getOpenAccounts() {
    return moneyObjects.getAsList().where((a) => !(a as Account).isClosed()).toList();
  }

  static Account? get(id) {
    return moneyObjects.get(id) as Account?;
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
    for (var row in rows) {
      var id = num.parse(row["Id"].toString());
      var name = row["Name"].toString();
      var flags = int.parse(row["Flags"].toString());
      var type = int.parse(row["Type"].toString());

      var a = Account(id, name);
      a.flags = flags;
      a.type = AccountType.values[type];

      moneyObjects.addEntry(a);
    }
  }

  loadDemoData() {
    List<String> names = ['BankOfAmerica', 'BECU', 'FirstTech', 'Fidelity', 'Bank of Japan', 'Trust Canada', 'ABC Corp', 'Royal Bank', 'Unicorn', 'God-Inc'];
    for (int i = 0; i < names.length; i++) {
      moneyObjects.addEntry(Account(i, names[i]));
    }
  }

  static onAllDataLoaded() {
    for (var item in moneyObjects.getAsList()) {
      var a = item as Account;
      a.count = 0;
      a.balance = 0;
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
