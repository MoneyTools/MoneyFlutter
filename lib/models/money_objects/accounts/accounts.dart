import 'package:money/helpers/json_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:uuid/uuid.dart';

class Accounts extends MoneyObjects<Account> {
  @override
  String sqlQuery() {
    return 'SELECT * FROM Accounts';
  }

  @override
  Account instanceFromSqlite(final MyJson row) {
    return Account.fromSqlite(row);
  }

  @override
  void loadDemoData() {
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
      addEntry(
        Account()
          ..id.value = i
          ..accountId.value = i.toString()
          ..name.value = names[i]
          ..type.value = AccountType.checking
          ..description.value = 'Some description'
          ..currency.value = 'USD'
          ..lastSync.value = DateTime.now()
          ..syncGuid.value = const Uuid().v4().toString()
          ..flags.value = 0
          ..openingBalance.value = 0
          ..ofxAccountId.value = ''
          ..onlineAccount.value = -1
          ..webSite.value = ''
          ..reconcileWarning.value = 0
          ..lastBalance.value = DateTime.now().subtract(const Duration(days: 20))
          ..categoryIdForPrincipal.value = 0
          ..categoryIdForInterest.value = 0,
      );
    }
  }

  @override
  void onAllDataLoaded() {
    for (final Account account in getList()) {
      account.count.value = 0;
      account.balance.value = account.openingBalance.value;
    }

    for (final Transaction t in Data().transactions.getList()) {
      final Account? item = get(t.accountId.value);
      if (item != null) {
        item.count.value++;
        item.balance.value += t.amount.value;
      }
    }
  }

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
    return account.name.value;
  }

  Account? findByIdAndType(
    final String accountId,
    final AccountType accountType,
  ) {
    return getList().firstWhereOrNull((final Account item) {
      return item.accountId.value == accountId && item.type.value == accountType;
    });
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }
}
