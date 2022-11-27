import 'package:collection/collection.dart';
import 'package:money/models/transactions.dart';

class Payee {
  num id = -1;
  String accountId = "";
  String name = "";
  num count = 0;
  double amount = 0.00;
  double balance = 0.00;

  Payee(this.id, this.name);
}

class Payees {
  num runningBalance = 0;

  static List<Payee> list = [];
  static Map<num, Payee> map = {};

  static Payee? get(id) {
    return map[id];
  }

  static String getNameFromId(num id) {
    var payee = get(id);
    if (payee == null) {
      return id.toString();
    }
    return payee.name;
  }

  static addEntry(Payee payee) {
    list.add(payee);
    map[payee.id] = payee;
  }

  load(rows) async {
    runningBalance = 0;

    /*
     */
    for (var row in rows) {
      var id = num.parse(row["Id"].toString());
      var name = row["Name"].toString();
      addEntry(Payee(id, name));
    }
    return list;
  }

  loadDemoData() {
    List<String> names = ['John', 'Paul', 'George', 'Ringo', 'Jean-Pierre', 'Chris', 'Bill', 'Steve', 'Sue', 'Barbara'];
    for (var i = 0; i < names.length; i++) {
      addEntry(Payee(i, names[i]));
    }
  }

  static onAllDataLoaded() {
    for (var item in list) {
      item.count = 0;
      item.balance = 0;
    }

    for (var t in Transactions.list) {
      var item = get(t.payeeId);
      if (item != null) {
        item.count++;
        item.balance += t.amount;
      }
    }
  }
}
