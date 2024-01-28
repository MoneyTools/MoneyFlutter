import 'package:money/helpers/json_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

class Accounts extends MoneyObjects<Account> {
  @override
  String sqlQuery() {
    return 'SELECT * FROM Accounts';
  }

  @override
  Account instanceFromSqlite(final MyJson row) {
    return Account.fromJson(row);
  }

  @override
  void loadDemoData() {
    clear();
    final List<MyJson> demoAccounts = <MyJson>[
      // ignore: always_specify_types
      {'Id': 0, 'Name': 'BankOfAmerica', 'Type': AccountType.checking.index},
      // ignore: always_specify_types
      {'Id': 1, 'Name': 'Revolut UK', 'Type': AccountType.credit.index},
      // ignore: always_specify_types
      {'Id': 2, 'Name': 'Fidelity', 'Type': AccountType.investment.index},
      // ignore: always_specify_types
      {'Id': 3, 'Name': 'Bank of Japan', 'Type': AccountType.cash.index},
      // ignore: always_specify_types
      {'Id': 4, 'Name': 'Trust Canada', 'Type': AccountType.checking.index},
    ];
    for (final MyJson demoAccount in demoAccounts) {
      addEntry(Account.fromJson(demoAccount));
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
