import 'package:money/models/money_entity.dart';
import 'package:money/models/transactions.dart';

class Payee extends MoneyEntity {
  String accountId = "";
  num count = 0;
  double amount = 0.00;
  double balance = 0.00;

  Payee(super.id, super.name);
}

class Payees {
  static MoneyObjects moneyObjects = MoneyObjects();

  static Payee? get(id) {
    return moneyObjects.get(id) as Payee?;
  }

  static String getNameFromId(id) {
    return moneyObjects.getNameFromId(id);
  }

  clear() {
    moneyObjects.clear();
  }

  load(rows) async {
    clear();
    /*
     */
    for (var row in rows) {
      var id = num.parse(row["Id"].toString());
      var name = row["Name"].toString();
      moneyObjects.addEntry(Payee(id, name));
    }
  }

  loadDemoData() {
    clear();

    List<String> names = ['John', 'Paul', 'George', 'Ringo', 'Jean-Pierre', 'Chris', 'Bill', 'Steve', 'Sue', 'Barbara'];
    for (var i = 0; i < names.length; i++) {
      moneyObjects.addEntry(Payee(i, names[i]));
    }
  }

  static onAllDataLoaded() {
    for (var item in moneyObjects.getAsList()) {
      var payee = item as Payee;
      payee.count = 0;
      payee.balance = 0;
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
