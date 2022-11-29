import 'package:money/models/money_entity.dart';
import 'package:money/models/transactions.dart';

class Payee extends MoneyEntity {
  String accountId = "";
  num count = 0;
  double amount = 0.00;
  double balance = 0.00;

  Payee(id, name) : super(id, name) {
    //
  }
}

class Payees {
  static MoneyObjects moneyObjects = MoneyObjects();

  num runningBalance = 0;

  static Payee? get(id) {
    return moneyObjects.get(id) as Payee?;
  }

  static String getNameFromId(num id) {
    var payee = get(id);
    if (payee == null) {
      return id.toString();
    }
    return payee.name;
  }

  load(rows) async {
    runningBalance = 0;

    /*
     */
    for (var row in rows) {
      var id = num.parse(row["Id"].toString());
      var name = row["Name"].toString();
      moneyObjects.addEntry(Payee(id, name));
    }
  }

  loadDemoData() {
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
