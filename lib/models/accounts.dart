import 'package:collection/collection.dart';
import 'package:money/models/transactions.dart';


enum AccountType {
  savings,
  checking,
  moneyMarket,
  cash,
  credit,
  investment,
  retirement,
  _notUsed_7 ,   // There is a hole here from deleted type which we can fill when we invent new types, but the types 8-10 have to keep those numbers or else we mess up the existing databases.
  asset,              // Used for tracking Assets like "House, Car, Boat, Jewelry, this helps to make NetWorth more accurate
  categoryFund,       // a pseudo account for managing category budgets
  loan,
  creditLine
}

enum AccountFlags {
  none,
  budgeted,
  closed,
  raxDeferred
}


class Account {
  num id = -1;
  String name = "";
  int count = 0;
  double balance = 0.00;
  int flags = 0;

  Account(this.id, this.name);


  isClosed() {
    return (flags & AccountFlags.closed.index) != 0;
  }


}


class Accounts {
  num runningBalance = 0;

  static List<Account> list = [];

  static getOpenAccounts(){
    return list.where((a)=>!a.isClosed()).toList();
  }

  static Account? get(accountId) {
    return list.firstWhereOrNull((item) => item.id == accountId);
  }

  String getNameFromId(num id) {
    var account = get(id);
    if (account == null) {
      return id.toString();
    }
    return account.name;
  }


  load(rows) async {
    runningBalance = 0;

    for (var row in rows) {
      var id = num.parse(row["Id"].toString());
      var name = row["Name"].toString();
      var flags = int.parse(row["Flags"].toString());

      var a = Account(id, name);
      a.flags = flags;

      list.add(a);
    }
    return list;
  }

  loadScale() {
    List<String> names = ['BankOfAmerica', 'BECU', 'FirstTech','Fidelity','Bank of Japan', 'Trust Canada', 'ABC Corp', 'Royal Bank', 'Unicorn', 'God-Inc'];
    list = List<Account>.generate(10, (i) => Account(i, names[i]));
  }

  static onAllDataLoaded(){
    for (var item in list)
    {
      item.count = 0;
      item.balance = 0;
    }

    for (var t in Transactions.list)
    {
      var account = get(t.accountId);
      if (account != null)
      {
        account.count++;
        account.balance += t.amount;
      }
    }
  }
}
