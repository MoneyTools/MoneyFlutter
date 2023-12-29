import 'package:money/models/money_entity.dart';
import 'package:money/models/transactions.dart';

enum CategoryType {
  none, // 0
  income, // 1
  expense, // 2
  saving, // 3
  reserved, // 4
  transfer, // 5
  investment, // 6
}

class Category extends MoneyEntity {
  num parentId = -1;
  CategoryType type = CategoryType.none;
  num count = 0;
  double balance = 0.00;

  Category(final num id, this.type, final String name) : super(id, name) {
    //
  }

  getTypeAsText() {
    switch (type) {
      case CategoryType.income:
        return 'Income';
      case CategoryType.expense:
        return 'Expense';
      case CategoryType.saving:
        return 'Saving';
      case CategoryType.reserved:
        return 'Reserved';
      case CategoryType.transfer:
        return 'Transfer';
      case CategoryType.investment:
        return 'Investment';
      case CategoryType.none:
      default:
        return 'None';
    }
  }

  static CategoryType getTypeFromText(final String text) {
    switch (text) {
      case '1':
        return CategoryType.income;
      case '2':
        return CategoryType.expense;
      case '3':
        return CategoryType.saving;
      case '4':
        return CategoryType.reserved;
      case '5':
        return CategoryType.transfer;
      case '6':
        return CategoryType.investment;
      case '0':
      default:
        return CategoryType.none;
    }
  }
}

class Categories {
  static MoneyObjects<Category> moneyObjects = MoneyObjects<Category>();
  static num idOfSplitCategory = -1;

  static Category? get(final num id) {
    return moneyObjects.get(id);
  }

  static String getNameFromId(final num id) {
    if (id == -1) {
      return '';
    }

    if (id == splitCategoryId()) {
      return '<Split>';
    }
    return moneyObjects.getNameFromId(id);
  }

  static num splitCategoryId() {
    if (idOfSplitCategory == -1) {
      final Category? cat = moneyObjects.getByName('Split');
      if (cat != null) {
        idOfSplitCategory = cat.id;
      }
    }
    return idOfSplitCategory;
  }

  static Category? getTopAncestor(final Category category) {
    if (category.parentId == -1) {
      return category; // this is the top
    }
    final Category? parent = get(category.parentId);
    if (parent == null) {
      return category;
    }
    return getTopAncestor(parent);
  }

  static List<num> getTreeIds(final num rootIdToStartFrom) {
    final List<num> list = <num>[];
    if (rootIdToStartFrom > 0) {
      getTreeIdsRecursive(rootIdToStartFrom, list);
    }
    return list;
  }

  static void getTreeIdsRecursive(final num categoryId, final List<num> list) {
    if (categoryId > 0) {
      list.add(categoryId);
      final List<Category> descendants = getCategoriesWithThisParent(categoryId);
      for (final Category c in descendants) {
        // debugLog(c.id.toString()+"="+c.name);
        getTreeIdsRecursive(c.id, list);
      }
    }
  }

  static List<Category> getCategoriesWithThisParent(final num parentId) {
    final List<Category> list = <Category>[];
    for (final Category item in Categories.moneyObjects.getAsList()) {
      if (item.parentId == parentId) {
        list.add(item);
      }
    }
    return list;
  }

  clear() {
    moneyObjects.clear();
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
  load(final List<Map<String, Object?>> rows) async {
    clear();
    for (final Map<String, Object?> row in rows) {
      final num id = num.parse(row['Id'].toString());
      final String name = row['Name'].toString();
      final Object? rt = row['Type'];
      final Category newEntry = Category(
        id,
        Category.getTypeFromText(rt.toString()),
        name,
      );
      newEntry.parentId = num.parse(row['ParentId'].toString());

      moneyObjects.addEntry(newEntry);
    }
  }

  loadDemoData() {
    clear();
    moneyObjects.addEntry(Category(0, CategoryType.income, 'Paychecks'));
    moneyObjects.addEntry(Category(1, CategoryType.investment, 'Investment'));
    moneyObjects.addEntry(Category(2, CategoryType.income, 'Interests'));
    moneyObjects.addEntry(Category(3, CategoryType.income, 'Rental'));
    moneyObjects.addEntry(Category(4, CategoryType.none, 'Lottery'));
    moneyObjects.addEntry(Category(5, CategoryType.expense, 'Mortgage'));
    moneyObjects.addEntry(Category(6, CategoryType.income, 'Saving'));
    moneyObjects.addEntry(Category(7, CategoryType.expense, 'Bills'));
    moneyObjects.addEntry(Category(8, CategoryType.expense, 'Taxes'));
    moneyObjects.addEntry(Category(9, CategoryType.expense, 'School'));
  }

  static onAllDataLoaded() {
    for (final Category category in moneyObjects.getAsList()) {
      category.count = 0;
      category.balance = 0;
    }

    for (final Transaction t in Transactions.list) {
      final Category? item = get(t.categoryId);
      if (item != null) {
        item.count++;
        item.balance += t.amount;
      }
    }
  }
}
