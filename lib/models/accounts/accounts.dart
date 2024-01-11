import 'package:collection/collection.dart';
import 'package:money/models/accounts/account.dart';
import 'package:money/models/transactions/transaction.dart';
import 'package:money/models/transactions/transactions.dart';

import 'package:money/models/money_entity.dart';

class Accounts {
  static MoneyObjects<Account> moneyObjects = MoneyObjects<Account>();

  static List<Account> getOpenAccounts() {
    return moneyObjects.getAsList().where((final Account item) => activeBankAccount(item)).toList();
  }

  static bool activeBankAccount(final Account element) {
    return element.isActiveBankAccount();
  }

  static List<Account> activeAccount(
    final List<AccountType> types, {
    final bool? isActive = true,
  }) {
    return moneyObjects.getAsList().where((final Account item) {
      if (!item.matchType(types)) {
        return false;
      }
      if (isActive == null) {
        return true;
      }
      return item.isActive() == isActive;
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

  static Account? findByIdAndType(
    final String accountId,
    final AccountType accountType,
  ) {
    return moneyObjects.getAsList().firstWhereOrNull((final Account item) {
      return item.accountId == accountId && item.type == accountType;
    });
  }

  clear() {
    moneyObjects.clear();
  }

  static List<Account> list() {
    return moneyObjects.getAsList();
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
      final Account a = Account(
        int.parse(row['Id'].toString()),
        row['Name'].toString(),
      );
      a.accountId = row['AccountId'].toString();
      a.flags = int.parse(row['Flags'].toString());
      a.type = AccountType.values[int.parse(row['Type'].toString())];
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

  static String toCSV() {
    final StringBuffer csv = StringBuffer();
    csv.writeln('"id","accountId","type","ofxAccountId","description","flags"');

    for (final Account account in Accounts.moneyObjects.getAsList()) {
      csv.writeln(
        '"${account.id}","${account.accountId}","${account.type.index}","${account.ofxAccountId}","${account.description}","${account.flags}"',
      );
    }
    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    return '\uFEFF$csv';
  }
}
