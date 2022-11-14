import 'package:collection/collection.dart';

class Category {
  num id = -1;
  String name = "";
  double balance = 0.00;

  Category(this.id, this.name);
}

class Categories {
  num runningBalance = 0;

  List<Category> list = [];

  Category? get(accountId) {
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

  loadScale() {
    List<String> names = ['BankOfAmerica', 'BECU', 'FirstTech', 'Fidelity', 'Bank of Japan', 'Trust Canada', 'ABC Corp', 'Royal Bank', 'Unicorn', 'God-Inc'];
    list = List<Category>.generate(10, (i) => Category(i, names[i]));
  }
}
