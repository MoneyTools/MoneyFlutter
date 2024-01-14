import 'package:collection/collection.dart';
import 'package:money/helpers/json_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

import 'package:uuid/uuid.dart';

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

  load(final List<Json> rows) async {
    clear();
    for (final Json row in rows) {
      final Account a = Account.fromSqlite(row);
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
      moneyObjects.addEntry(Account(
        id: i,
        name: names[i],
        accountId: i.toString(),
        type: AccountType.checking,
        description: 'Some description',
        currency: 'USD',
        lastSync: DateTime.now(),
        syncGuid: const Uuid().v4().toString(),
        flags: 0,
        openingBalance: 0,
        ofxAccountId: '',
        onlineAccount: -1,
        webSite: '',
        reconcileWarning: 0,
        lastBalance: 0.0,
        categoryIdForPrincipal: 0,
        categoryIdForInterest: 0,
      ));
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
