import 'package:money/helpers/json_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/categories/category.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

class Categories extends MoneyObjects<Category> {
  static int idOfSplitCategory = -1;

  String getNameFromId(final int id) {
    if (id == -1) {
      return '';
    }

    if (id == splitCategoryId()) {
      return '<Split>';
    }
    final Category? category = get(id);
    return category == null ? '' : category.name;
  }

  int splitCategoryId() {
    if (idOfSplitCategory == -1) {
      final Category? cat = getByName('Split');
      if (cat != null) {
        idOfSplitCategory = cat.id;
      }
    }
    return idOfSplitCategory;
  }

  Category? getByName(final String name) {
    return getList().firstWhereOrNull((final Category category) => category.name == name);
  }

  Category getTopAncestor(final Category category) {
    if (category.parentId == -1) {
      return category; // this is the top
    }
    final Category? parent = get(category.parentId);
    if (parent == null) {
      return category;
    }
    return getTopAncestor(parent);
  }

  List<int> getTreeIds(final int rootIdToStartFrom) {
    final List<int> list = <int>[];
    if (rootIdToStartFrom > 0) {
      getTreeIdsRecursive(rootIdToStartFrom, list);
    }
    return list;
  }

  void getTreeIdsRecursive(final int categoryId, final List<int> list) {
    if (categoryId > 0) {
      list.add(categoryId);
      final List<Category> descendants = getCategoriesWithThisParent(categoryId);
      for (final Category c in descendants) {
        // debugLog(c.id.toString()+"="+c.name);
        getTreeIdsRecursive(c.id, list);
      }
    }
  }

  List<Category> getCategoriesWithThisParent(final int parentId) {
    final List<Category> list = <Category>[];
    for (final Category item in getList()) {
      if (item.parentId == parentId) {
        list.add(item);
      }
    }
    return list;
  }

  Category getOrCreateCategory(
    final String name,
    final CategoryType type,
  ) {
    Category? category = getByName(name);

    if (category == null) {
      category = Category(
        id: length,
        name: name,
        type: type,
      );
      addEntry(category);
    }
    // TODO
    // else if (result.IsDeleted) {
    //   result.Undelete();
    // }
    return category;
  }

  Category get split {
    return getOrCreateCategory("Split", CategoryType.none);
  }

  Category get salesTax {
    return getOrCreateCategory("Taxes:Sales Tax", CategoryType.expense);
  }

  Category get interestEarned {
    return getOrCreateCategory("Savings:Interest", CategoryType.income);
  }

  Category get savings {
    return getOrCreateCategory("Savings", CategoryType.income);
  }

  Category get investmentCredit {
    return getOrCreateCategory("Investments:Credit", CategoryType.income);
  }

  Category get investmentDebit {
    return getOrCreateCategory("Investments:Debit", CategoryType.expense);
  }

  Category get investmentInterest {
    return getOrCreateCategory("Investments:Interest", CategoryType.income);
  }

  Category get investmentDividends {
    return getOrCreateCategory("Investments:Dividends", CategoryType.income);
  }

  Category get investmentTransfer {
    return getOrCreateCategory("Investments:Transfer", CategoryType.none);
  }

  Category get investmentFees {
    return getOrCreateCategory("Investments:Fees", CategoryType.expense);
  }

  Category get investmentMutualFunds {
    return getOrCreateCategory("Investments:Mutual Funds", CategoryType.expense);
  }

  Category get investmentStocks {
    return getOrCreateCategory("Investments:Stocks", CategoryType.expense);
  }

  Category get investmentOther {
    return getOrCreateCategory("Investments:Other", CategoryType.expense);
  }

  Category get investmentBonds {
    return getOrCreateCategory("Investments:Bonds", CategoryType.expense);
  }

  Category get investmentOptions {
    return getOrCreateCategory("Investments:Options", CategoryType.expense);
  }

  Category get investmentReinvest {
    return getOrCreateCategory("Investments:Reinvest", CategoryType.none);
  }

  Category get investmentLongTermCapitalGainsDistribution {
    return getOrCreateCategory("Investments:Long Term Capital Gains Distribution", CategoryType.income);
  }

  Category get investmentShortTermCapitalGainsDistribution {
    return getOrCreateCategory("Investments:Short Term Capital Gains Distribution", CategoryType.income);
  }

  Category get investmentMiscellaneous {
    return getOrCreateCategory("Investments:Miscellaneous", CategoryType.expense);
  }

  Category get transferToDeletedAccount {
    return getOrCreateCategory("Xfer to Deleted Account", CategoryType.none);
  }

  Category get transferFromDeletedAccount {
    return getOrCreateCategory("Xfer from Deleted Account", CategoryType.none);
  }

  Category get transfer {
    return getOrCreateCategory("Transfer", CategoryType.none);
  }

  Category get unknown {
    return getOrCreateCategory("Unknown", CategoryType.none);
  }

  Category get unassignedSplit {
    return getOrCreateCategory("UnassignedSplit", CategoryType.none);
  }

  load(final List<Json> rows) async {
    clear();
    for (final Json row in rows) {
      addEntry(Category.fromSqlite(row));
    }
  }

  loadDemoData() {
    clear();
    addEntry(Category(id: 0, name: 'Paychecks', description: '', type: CategoryType.income));
    addEntry(Category(id: 1, name: 'Investment', description: '', type: CategoryType.investment));
    addEntry(Category(id: 2, name: 'Interests', description: '', type: CategoryType.income));
    addEntry(Category(id: 3, name: 'Rental', description: '', type: CategoryType.income));
    addEntry(Category(id: 4, name: 'Lottery', description: '', type: CategoryType.none));
    addEntry(Category(id: 5, name: 'Mortgage', description: '', type: CategoryType.expense));
    addEntry(Category(id: 6, name: 'Saving', description: '', type: CategoryType.income));
    addEntry(Category(id: 7, name: 'Bills', description: '', type: CategoryType.expense));
    addEntry(Category(id: 8, name: 'Taxes', description: '', type: CategoryType.expense));
    addEntry(Category(id: 9, name: 'School', description: '', type: CategoryType.expense));
  }

  onAllDataLoaded() {
    for (final Category category in getList()) {
      category.count = 0;
      category.balance = 0;
    }

    for (final Transaction t in Data().transactions.getList()) {
      final Category? item = get(t.categoryId);
      if (item != null) {
        item.count++;
        item.balance += t.amount;
      }
    }
  }

  String toCSV() {
    final StringBuffer csv = StringBuffer();

    // CSV Header
    csv.writeln(Category.getFieldDefinitions().getCsvHeader());

    // CSV Rows
    for (final Category item in getList()) {
      csv.writeln(Category.getFieldDefinitions().getCsvRowValues(item));
    }
    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    return '\uFEFF$csv';
  }
}