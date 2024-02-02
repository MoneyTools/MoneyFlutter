import 'package:flutter/foundation.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/data_io/database/database.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

class Accounts extends MoneyObjects<Account> {
  @override
  Account instanceFromSqlite(final MyJson row) {
    return Account.fromJson(row);
  }

  @override
  void loadDemoData() {
    clear();
    final List<MyJson> demoAccounts = <MyJson>[
      // ignore: always_specify_types
      {
        'Id': 0,
        'AccountId': 'BankAccountIdForTesting',
        'Name': 'U.S. Bank',
        'Type': AccountType.savings.index,
        'Currency': 'USD'
      },
      // ignore: always_specify_types
      {'Id': 1, 'Name': 'Bank Of America', 'Type': AccountType.checking.index, 'Currency': 'USD'},
      // ignore: always_specify_types
      {'Id': 2, 'Name': 'KeyBank', 'Type': AccountType.moneyMarket.index, 'Currency': 'USD'},
      // ignore: always_specify_types
      {'Id': 3, 'Name': 'Mattress', 'Type': AccountType.cash.index, 'Currency': 'USD'},
      // ignore: always_specify_types
      {'Id': 4, 'Name': 'Revolut UK', 'Type': AccountType.credit.index, 'Currency': 'GBP'},
      // ignore: always_specify_types
      {'Id': 5, 'Name': 'Fidelity', 'Type': AccountType.investment.index, 'Currency': 'USD'},
      // ignore: always_specify_types
      {'Id': 6, 'Name': 'Bank of Japan', 'Type': AccountType.retirement.index, 'Currency': 'JPY'},
      // ignore: always_specify_types
      {'Id': 7, 'Name': 'James Bonds', 'Type': AccountType.asset.index, 'Currency': 'GBP'},
      // ignore: always_specify_types
      {'Id': 8, 'Name': 'KickStarter', 'Type': AccountType.loan.index, 'Currency': 'CAD'},
      // ignore: always_specify_types
      {'Id': 9, 'Name': 'Home Remodel', 'Type': AccountType.creditLine.index, 'Currency': 'USD'},
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
      account.balanceNormalized.value = account.openingBalance.value * account.getCurrencyRatio();
    }

    for (final Transaction t in Data().transactions.getList()) {
      final Account? item = get(t.accountId.value);
      if (item != null) {
        item.count.value++;
        item.balance.value += t.amount.value;
        item.balanceNormalized.value += t.getNormalizedAmount();
      }
    }
  }

  List<Account> getOpenAccounts() {
    return getList().where((final Account item) => activeBankAccount(item)).toList();
  }

  @override
  bool saveSql(final MyDatabase db) {
    for (final Account a in getList()) {
      switch (a.change) {
        case ChangeType.none:
          break;
        case ChangeType.inserted:
          /*
            sb += "INSERT INTO Accounts (Id,AccountId,OfxAccountId,Name,Type,Description,OnlineAccount,OpeningBalance,LastSync,LastBalance,SyncGuid,Flags,Currency,WebSite,ReconcileWarning,CategoryIdForPrincipal,CategoryIdForInterest) VALUES (");
            sb += string.Format("{0}", a.Id.ToString()));
            sb += string.Format(",'{0}'", DBString(a.AccountId)));
            sb += string.Format(",'{0}'", DBString(a.OfxAccountId)));
            sb += string.Format(",'{0}'", DBString(a.Name)));
            sb += string.Format(",{0}", ((int)a.Type).ToString()));
            sb += string.Format(",'{0}'", DBString(a.Description)));
            sb += string.Format(",{0}", a.OnlineAccount != null ? a.OnlineAccount.Id.ToString() : "-1"));
            sb += string.Format(",{0}", a.OpeningBalance.ToString()));
            sb += string.Format(",{0}", DBDateTime(a.LastSync)));
            sb += string.Format(",{0}", DBDateTime(a.LastBalance)));
            sb += string.Format(",{0}", DBGuid(a.SyncGuid)));
            sb += string.Format(",{0}", ((int)a.Flags).ToString()));
            sb += string.Format(",'{0}'", DBString(a.Currency)));
            sb += string.Format(",'{0}'", DBString(a.WebSite)));
            sb += string.Format(",{0}", a.ReconcileWarning));
            sb += string.Format(",'{0}'", a.CategoryForPrincipal == null ? "-1" : a.CategoryForPrincipal.Id.ToString()));
            sb += string.Format(",'{0}'", a.CategoryForInterest == null ? "-1" : a.CategoryForInterest.Id.ToString()));
            sb.AppendLine(");");
           */
          db.insert('Accounts', {'name': 'John Doe', 'age': 30});

        case ChangeType.deleted:
        /*
            sb.AppendLine("-- deleting account: " + a.Name);
            sb.AppendLine(string.Format("DELETE FROM Accounts WHERE Id={0};", a.Id.ToString()));
           */
        case ChangeType.changed:
        /*
              sb.AppendLine("-- updating account: " + a.Name);
              sb += "UPDATE Accounts SET ");
              sb += string.Format("AccountId='{0}'", DBString(a.AccountId)));
              sb += string.Format(",OfxAccountId='{0}'", DBString(a.OfxAccountId)));
              sb += string.Format(",Name='{0}'", DBString(a.Name)));
              sb += string.Format(",Type={0}", ((int)a.Type).ToString()));
              sb += string.Format(",Description='{0}'", DBString(a.Description)));
              sb += string.Format(",OnlineAccount={0}", a.OnlineAccount != null ? a.OnlineAccount.Id.ToString() : "-1"));
              sb += string.Format(",OpeningBalance={0}", a.OpeningBalance.ToString()));
              sb += string.Format(",LastSync={0}", DBDateTime(a.LastSync)));
              sb += string.Format(",LastBalance={0}", DBDateTime(a.LastBalance)));
              sb += string.Format(",SyncGuid={0}", DBGuid(a.SyncGuid)));
              sb += string.Format(",Flags={0}", ((int)a.Flags).ToString()));
              sb += string.Format(",Currency='{0}'", DBString(a.Currency)));
              sb += string.Format(",WebSite='{0}'", DBString(a.WebSite)));
              sb += string.Format(",ReconcileWarning={0}", a.ReconcileWarning));
              sb += string.Format(",CategoryIdForPrincipal='{0}'", a.CategoryForPrincipal == null ? "-1" : a.CategoryForPrincipal.Id.ToString()));
              sb += string.Format(",CategoryIdForInterest='{0}'", a.CategoryForInterest == null ? "-1" : a.CategoryForInterest.Id.ToString()));

              sb.AppendLine(string.Format(" WHERE Id={0};", a.Id));
           */
        default:
          debugPrint('Unhandled change ${a.change}');
      }
    }
    return false;
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
