import 'package:collection/collection.dart';

class Account {
  num id = -1;
  String name = "";
  double balance = 0.00;

  Account(this.id, this.name);
}

class Accounts {
  num runningBalance = 0;

  List<Account> list = [];

  Account? get(accountId) {
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
      list.add(Account(id, name));
    }
    return list;
  }

  loadScale() {
    List<String> names = ['BankOfAmerica', 'BECU', 'FirstTech','Fidelity','Bank of Japan', 'Trust Canada', 'ABC Corp', 'Royal Bank', 'Unicorn', 'God-Inc'];
    list = List<Account>.generate(10, (i) => Account(i, names[i]));
  }
}
