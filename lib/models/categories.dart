import 'package:collection/collection.dart';
import 'package:money/models/transactions.dart';

enum CategoryType { none, income, expense, saving, investment }

class Category {
  num id = -1;
  num parentId = -1;
  String name = "";
  CategoryType type = CategoryType.none;
  num count = 0;
  double balance = 0.00;

  Category(this.id, this.name);

  getTypeAsText() {
    switch (type) {
      case CategoryType.income:
        return "Income";
      case CategoryType.expense:
        return "Expense";
      case CategoryType.saving:
        return "Saving";
      case CategoryType.investment:
        return "Investment";
      case CategoryType.none:
      default:
        return "None";
    }
  }
}

class Categories {
  num runningBalance = 0;

  static List<Category> list = [];

  static Category? get(id) {
    return list.firstWhereOrNull((item) => item.id == id);
  }

  String getNameFromId(num id) {
    var account = get(id);
    if (account == null) {
      return id.toString();
    }
    return account.name;
  }

  static Category? getTopAncestor(Category category) {
    if (category.parentId == -1) {
      return category; // this is the top
    }
    var parent = get(category.parentId);
    if (parent == null) {
      return category;
    }
    return getTopAncestor(parent);
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
      var newEntry = Category(id, name);
      newEntry.parentId = num.parse(row["ParentId"].toString());

      try {
        var rt = row["Type"];
        var rtt = rt.toString();
        switch (rtt) {
          case "1":
            newEntry.type = CategoryType.income;
            break;
          case "2":
            newEntry.type = CategoryType.expense;
            break;
          case "3":
            newEntry.type = CategoryType.saving;
            break;
          case "4":
            newEntry.type = CategoryType.investment;
            break;
          case "0":
          default:
            newEntry.type = CategoryType.none;
        }
      } catch (e) {
        print(e);
      }
      list.add(newEntry);
    }
    return list;
  }

  loadDemoData() {
    List<String> names = ['BankOfAmerica', 'BECU', 'FirstTech', 'Fidelity', 'Bank of Japan', 'Trust Canada', 'ABC Corp', 'Royal Bank', 'Unicorn', 'God-Inc'];
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
