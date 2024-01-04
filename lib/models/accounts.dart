import 'package:money/models/transactions.dart';

import 'package:money/models/money_entity.dart';

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
  double openingBalance = 0.00;
  double balance = 0.00;
  int flags = 0;
  AccountType type = AccountType.checking;

  Account(super.id, super.name);

  bool isClosed() {
    return (flags & AccountFlags.closed.index) != 0;
  }

  bool isActive() {
    return !isClosed();
  }

  bool matchType(final List<AccountType> types) {
    if (types.isEmpty) {
      // All accounts except these
      return type != AccountType._notUsed_7 && type != AccountType.categoryFund;
    }
    return types.contains(type);
  }

  bool isBankAccount() {
    return type == AccountType.savings || type == AccountType.checking || type == AccountType.cash;
  }

  bool isActiveBankAccount() {
    return isBankAccount() && isActive();
  }

  getTypeAsText() {
    switch (type) {
      case AccountType.savings:
        return 'Savings';
      case AccountType.checking:
        return 'Checking';
      case AccountType.moneyMarket:
        return 'MoneyMarket';
      case AccountType.cash:
        return 'Cash';
      case AccountType.credit:
        return 'Credit';
      case AccountType.investment:
        return 'Investment';
      case AccountType.retirement:
        return 'Retirement';
      case AccountType.asset:
        return 'Asset';
      case AccountType.categoryFund:
        return 'CategoryFund';
      case AccountType.loan:
        return 'Loan';
      case AccountType.creditLine:
        return 'CreditLine';
      default:
        break;
    }

    return 'other $type';
  }
}

class Accounts {
  static MoneyObjects<Account> moneyObjects = MoneyObjects<Account>();

  static List<Account> getOpenAccounts() {
    return moneyObjects.getAsList().where((final Account item) => activeBankAccount(item)).toList();
  }

  static bool activeBankAccount(final Account element) {
    return element.isActiveBankAccount();
  }

  static List<Account> activeAccount(final List<AccountType> types, {final bool? isActive = true}) {
    return moneyObjects.getAsList().where((final Account item) {
      return item.isActive() == isActive && item.matchType(types);
    }).toList();
  }

  static Account? get(final num id) {
    return moneyObjects.get(id);
  }

  static String getNameFromId(final num id) {
    final Account? account = get(id);
    if (account == null) {
      return id.toString();
    }
    return account.name;
  }

  clear() {
    moneyObjects.clear();
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
  load(final List<Map<String, Object?>> rows) async {
    clear();
    for (final Map<String, Object?> row in rows) {
      final int id = int.parse(row['Id'].toString());
      final String name = row['Name'].toString();
      final int flags = int.parse(row['Flags'].toString());
      final int type = int.parse(row['Type'].toString());

      final Account a = Account(id, name);
      a.flags = flags;
      a.type = AccountType.values[type];
      a.openingBalance = double.parse(row['OpeningBalance'].toString());

      moneyObjects.addEntry(a);
    }
  }

  loadDemoData() {
    clear();
    final List<String> names = <String>[
      'BankOfAmerica',
      'BECU',
      'FirstTech',
      'Fidelity',
      'Bank of Japan',
      'Trust Canada',
      'ABC Corp',
      'Royal Bank',
      'Unicorn',
      'God-Inc'
    ];
    for (int i = 0; i < names.length; i++) {
      moneyObjects.addEntry(Account(i, names[i]));
    }
  }

  static onAllDataLoaded() {
    for (final Account account in moneyObjects.getAsList()) {
      account.count = 0;
      account.balance = account.openingBalance;
    }

    for (final Transaction t in Transactions.list) {
      final Account? item = get(t.accountId);
      if (item != null) {
        item.count++;
        item.balance += t.amount;
      }
    }
  }
}
