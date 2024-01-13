import 'package:collection/collection.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_entities/accounts/account.dart';
import 'package:money/models/money_entities/transactions/transaction.dart';

import 'package:money/models/money_entities/money_entity.dart';

class Accounts {
  MoneyObjects<Account> moneyObjects = MoneyObjects<Account>();

  List<Account> getOpenAccounts() {
    return moneyObjects.getAsList().where((final Account item) => activeBankAccount(item)).toList();
  }

  bool activeBankAccount(final Account element) {
    return element.isActiveBankAccount();
  }

  List<Account> activeAccount(
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

  Account? get(final num id) {
    return moneyObjects.get(id);
  }

  String getNameFromId(final num id) {
    final Account? account = get(id);
    if (account == null) {
      return id.toString();
    }
    return account.name;
  }

  Account? findByIdAndType(
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

  List<Account> list() {
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

  onAllDataLoaded() {
    for (final Account account in moneyObjects.getAsList()) {
      account.count = 0;
      account.balance = account.openingBalance;
    }

    for (final Transaction t in Data().transactions.list) {
      final Account? item = get(t.accountId);
      if (item != null) {
        item.count++;
        item.balance += t.amount;
      }
    }
  }

  String toCSV() {
    final StringBuffer csv = StringBuffer();

    // CSV Header
    csv.writeln(Account.getFieldDefinitions().getCsvHeader());

    // CSV Rows
    for (final Account item in moneyObjects.getAsList()) {
      csv.writeln(Account.getFieldDefinitions().getCsvRowValues(item));
    }

    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    return '\uFEFF$csv';
  }
}
