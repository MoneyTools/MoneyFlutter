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

  Category(this.id, this.type, this.name);

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

  static getTypeFromText(text) {
    switch (text) {
      case "1":
        return CategoryType.income;

      case "2":
        return CategoryType.expense;

      case "3":
        return CategoryType.saving;
      case "4":
        return CategoryType.investment;
      case "0":
      default:
        return CategoryType.none;
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
      var rt = row["Type"];
      var newEntry = Category(id, Category.getTypeFromText(rt.toString()), name);
      newEntry.parentId = num.parse(row["ParentId"].toString());

      list.add(newEntry);
    }
    return list;
  }

  loadDemoData() {
    list.add(Category(0, CategoryType.income, 'Paychecks'));
    list.add(Category(1, CategoryType.investment, 'Investment'));
    list.add(Category(2, CategoryType.income, 'Interests'));
    list.add(Category(3, CategoryType.income, 'Rental'));
    list.add(Category(4, CategoryType.none, 'Lottery'));
    list.add(Category(5, CategoryType.expense, 'Mortgage'));
    list.add(Category(6, CategoryType.income, 'Saving'));
    list.add(Category(7, CategoryType.expense, 'Bills'));
    list.add(Category(8, CategoryType.expense, 'Taxes'));
    list.add(Category(9, CategoryType.expense, 'School'));
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
