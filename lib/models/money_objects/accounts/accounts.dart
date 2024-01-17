import 'package:money/helpers/json_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_objects.dart';

import 'package:money/models/money_objects/transactions/transaction.dart';

import 'package:uuid/uuid.dart';

class Accounts extends MoneyObjects<Account> {
  List<Account> getOpenAccounts() {
    return getList().where((final Account item) => activeBankAccount(item)).toList();
  }

  bool activeBankAccount(final Account element) {
    return element.isActiveBankAccount();
  }

  List<Account> activeAccount(
    final List<AccountType> types, {
    final bool? isActive = true,
  }) {
    return getList().where((final Account item) {
      if (!item.matchType(types)) {
        return false;
      }
      if (isActive == null) {
        return true;
      }
      return item.isActive() == isActive;
    }).toList();
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
    return getList().firstWhereOrNull((final Account item) {
      return item.accountId == accountId && item.type == accountType;
    });
  }

  List<Account> list() {
    return getList();
  }

  load(final List<Json> rows) async {
    clear();
    for (final Json row in rows) {
      final Account a = Account.fromSqlite(row);
      addEntry(a);
    }
  }

  loadDemoData() {
    clear();
    final List<String> names = <String>[
      'BankOfAmerica',
      'Revolut',
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
      addEntry(Account(
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
        lastBalance: DateTime.now().subtract(const Duration(days: 20)),
        categoryIdForPrincipal: 0,
        categoryIdForInterest: 0,
      ));
    }
  }

  onAllDataLoaded() {
    for (final Account account in getList()) {
      account.count = 0;
      account.balance = account.openingBalance;
    }

    for (final Transaction t in Data().transactions.getList()) {
      final Account? item = get(t.accountId);
      if (item != null) {
        item.count++;
        item.balance += t.amount;
      }
    }
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      Account.getFieldDefinitions(),
      getListSortedById(),
    );
  }
}
