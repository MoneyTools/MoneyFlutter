import 'package:collection/collection.dart';
import 'package:money/models/transactions.dart';

class Category {
  num id = -1;
  String name = "";
  num count = 0;
  double balance = 0.00;

  Category(this.id, this.name);
}

class Categories {
  num runningBalance = 0;

  static List<Category> list = [];

  static Category? get(accountId) {
    return list.firstWhereOrNull((item) => item.id == accountId);
  }

  String getNameFromId(num id) {
    var account = get(id);
    if (account == null) {
      return id.toString();
    }
    return account.name;
  }

  /*
      0 = "Id"
      1 = "ParentId"
      2 = "Name"
      3 = "Description"
      4 = "Type"
      5 = "Color"
      6 = "Budget"
      7 = "Balance"
      8 = "Frequency"
      9 = "TaxRefNum"
   */
  load(rows) async {
    runningBalance = 0;

    for (var row in rows) {
      var id = num.parse(row["Id"].toString());
      var name = row["Name"].toString();
      list.add(Category(id, name));
    }
    return list;
  }

  loadDemoData() {
    List<String> names = [
      'BankOfAmerica',
      'BECU',
      'FirstTech',
      'Fidelity',
      'Bank of Japan',
      'Trust Canada',
      'ABC Corp',
      'Royal Bank',
      'Unicorn',
      'God-Inc'
    ];
    list = List<Category>.generate(10, (i) => Category(i, names[i]));
  }

  static onAllDataLoaded() {
    for (var item in list) {
      item.count = 0;
      item.balance = 0;
    }

    for (var t in Transactions.list) {
      var item = get(t.categoryId);
      if (item != null) {
        item.count++;
        item.balance += t.amount;
      }
    }
  }
}
