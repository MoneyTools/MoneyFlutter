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
  int parentId = -1;
  CategoryType type = CategoryType.none;
  int count = 0;
  double balance = 0.00;

  Category(final int id, this.type, final String name) : super(id, name) {
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
  static int idOfSplitCategory = -1;

  static Category? get(final int id) {
    return moneyObjects.get(id);
  }

  static String getNameFromId(final int id) {
    if (id == -1) {
      return '';
    }

    if (id == splitCategoryId()) {
      return '<Split>';
    }
    return moneyObjects.getNameFromId(id);
  }

  static int splitCategoryId() {
    if (idOfSplitCategory == -1) {
      final Category? cat = moneyObjects.getByName('Split');
      if (cat != null) {
        idOfSplitCategory = cat.id;
      }
    }
    return idOfSplitCategory;
  }

  static Category getTopAncestor(final Category category) {
    if (category.parentId == -1) {
      return category; // this is the top
    }
    final Category? parent = get(category.parentId);
    if (parent == null) {
      return category;
    }
    return getTopAncestor(parent);
  }

  static List<int> getTreeIds(final int rootIdToStartFrom) {
    final List<int> list = <int>[];
    if (rootIdToStartFrom > 0) {
      getTreeIdsRecursive(rootIdToStartFrom, list);
    }
    return list;
  }

  static void getTreeIdsRecursive(final int categoryId, final List<int> list) {
    if (categoryId > 0) {
      list.add(categoryId);
      final List<Category> descendants = getCategoriesWithThisParent(categoryId);
      for (final Category c in descendants) {
        // debugLog(c.id.toString()+"="+c.name);
        getTreeIdsRecursive(c.id, list);
      }
    }
  }

  static List<Category> getCategoriesWithThisParent(final int parentId) {
    final List<Category> list = <Category>[];
    for (final Category item in Categories.moneyObjects.getAsList()) {
      if (item.parentId == parentId) {
        list.add(item);
      }
    }
    return list;
  }

  static Category getOrCreateCategory(
    final String name,
    final CategoryType type,
  ) {
    Category? category = moneyObjects.getByName(name);

    if (category == null) {
      category = Category(moneyObjects.length, type, name);
      moneyObjects.addEntry(category);
    }
    // TODO
    // else if (result.IsDeleted) {
    //   result.Undelete();
    // }
    return category;
  }

  clear() {
    moneyObjects.clear();
  }

  static Category get split {
    return Categories.getOrCreateCategory("Split", CategoryType.none);
  }

  static Category get salesTax {
    return Categories.getOrCreateCategory("Taxes:Sales Tax", CategoryType.expense);
  }

  static Category get interestEarned {
    return Categories.getOrCreateCategory("Savings:Interest", CategoryType.income);
  }

  static Category get savings {
    return Categories.getOrCreateCategory("Savings", CategoryType.income);
  }

  static Category get investmentCredit {
    return getOrCreateCategory("Investments:Credit", CategoryType.income);
  }

  static Category get investmentDebit {
    return getOrCreateCategory("Investments:Debit", CategoryType.expense);
  }

  static Category get investmentInterest {
    return getOrCreateCategory("Investments:Interest", CategoryType.income);
  }

  static Category get investmentDividends {
    return getOrCreateCategory("Investments:Dividends", CategoryType.income);
  }

  static Category get investmentTransfer {
    return getOrCreateCategory("Investments:Transfer", CategoryType.none);
  }

  static Category get investmentFees {
    return getOrCreateCategory("Investments:Fees", CategoryType.expense);
  }

  static Category get investmentMutualFunds {
    return Categories.getOrCreateCategory("Investments:Mutual Funds", CategoryType.expense);
  }

  static Category get investmentStocks {
    return Categories.getOrCreateCategory("Investments:Stocks", CategoryType.expense);
  }

  static Category get investmentOther {
    return Categories.getOrCreateCategory("Investments:Other", CategoryType.expense);
  }

  static Category get investmentBonds {
    return Categories.getOrCreateCategory("Investments:Bonds", CategoryType.expense);
  }

  static Category get investmentOptions {
    return Categories.getOrCreateCategory("Investments:Options", CategoryType.expense);
  }

  static Category get investmentReinvest {
    return Categories.getOrCreateCategory("Investments:Reinvest", CategoryType.none);
  }

  static Category get investmentLongTermCapitalGainsDistribution {
    return Categories.getOrCreateCategory("Investments:Long Term Capital Gains Distribution", CategoryType.income);
  }

  static Category get investmentShortTermCapitalGainsDistribution {
    return Categories.getOrCreateCategory("Investments:Short Term Capital Gains Distribution", CategoryType.income);
  }

  static Category get investmentMiscellaneous {
    return Categories.getOrCreateCategory("Investments:Miscellaneous", CategoryType.expense);
  }

  static Category get transferToDeletedAccount {
    return Categories.getOrCreateCategory("Xfer to Deleted Account", CategoryType.none);
  }

  static Category get transferFromDeletedAccount {
    return Categories.getOrCreateCategory("Xfer from Deleted Account", CategoryType.none);
  }

  static Category get transfer {
    return Categories.getOrCreateCategory("Transfer", CategoryType.none);
  }

  static Category get unknown {
    return Categories.getOrCreateCategory("Unknown", CategoryType.none);
  }

  static Category get unassignedSplit {
    return Categories.getOrCreateCategory("UnassignedSplit", CategoryType.none);
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
      final int id = int.parse(row['Id'].toString());
      final String name = row['Name'].toString();
      final Object? rt = row['Type'];
      final Category newEntry = Category(
        id,
        Category.getTypeFromText(rt.toString()),
        name,
      );
      newEntry.parentId = int.parse(row['ParentId'].toString());

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

  static String toCSV() {
    final StringBuffer csv = StringBuffer();
    csv.writeln('"id","parentId","type"');

    for (final Category category in Categories.moneyObjects.getAsList()) {
      csv.writeln(
        '"${category.id}","${category.parentId}","${category.type.index}"',
      );
    }
    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    return '\uFEFF$csv';
  }
}
