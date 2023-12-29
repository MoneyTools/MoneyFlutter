import 'package:money/models/money_entity.dart';
import 'package:money/models/transactions.dart';

class Payee extends MoneyEntity {
  String accountId = '';
  num count = 0;
  double amount = 0.00;
  double balance = 0.00;

  Payee(super.id, super.name);
}

class Payees {
  static MoneyObjects<Payee> moneyObjects = MoneyObjects<Payee>();

  static Payee? get(final num id) {
    return moneyObjects.get(id);
  }

  static String getNameFromId(final num id) {
    return moneyObjects.getNameFromId(id);
  }

  clear() {
    moneyObjects.clear();
  }

  load(final List<Map<String, Object?>> rows) async {
    clear();
    /*
     */
    for (final Map<String, Object?> row in rows) {
      final num id = num.parse(row['Id'].toString());
      final String name = row['Name'].toString();
      moneyObjects.addEntry(Payee(id, name));
    }
  }

  loadDemoData() {
    clear();

    final List<String> names = <String>['John', 'Paul', 'George', 'Ringo', 'Jean-Pierre', 'Chris', 'Bill', 'Steve', 'Sue', 'Barbara'];
    for (int i = 0; i < names.length; i++) {
      moneyObjects.addEntry(Payee(i, names[i]));
    }
  }

  static onAllDataLoaded() {
    for (final Payee payee in moneyObjects.getAsList()) {
      payee.count = 0;
      payee.balance = 0;
    }

    for (Transaction t in Transactions.list) {
      final Payee? item = get(t.payeeId);
      if (item != null) {
        item.count++;
        item.balance += t.amount;
      }
    }
  }
}
