import 'package:money/helpers/json_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/categories/category.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

class Categories extends MoneyObjects<Category> {
  @override
  String sqlQuery() {
    return 'SELECT * FROM Categories';
  }

  @override
  Category instanceFromSqlite(final Json row) {
    return Category.fromSqlite(row);
  }

  static int idOfSplitCategory = -1;

  String getNameFromId(final int id) {
    if (id == -1) {
      return '';
    }

    if (id == splitCategoryId()) {
      return '<Split>';
    }
    return Category.getName(get(id));
  }

  int splitCategoryId() {
    if (idOfSplitCategory == -1) {
      final Category? cat = getByName('Split');
      if (cat != null) {
        idOfSplitCategory = cat.id.value;
      }
    }
    return idOfSplitCategory;
  }

  Category? getByName(final String name) {
    return getList().firstWhereOrNull((final Category category) => category.name.value == name);
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
        getTreeIdsRecursive(c.id.value, list);
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
        name: name,
      )..type.value = type;

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

  @override
  loadDemoData() {
    clear();
    addEntry(Category(name: 'Paychecks', description: '', type: CategoryType.income)..id.value = 0);
    addEntry(Category(name: 'Investment', description: '', type: CategoryType.investment)..id.value = 1);
    addEntry(Category(name: 'Interests', description: '', type: CategoryType.income)..id.value = 2);
    addEntry(Category(name: 'Rental', description: '', type: CategoryType.income)..id.value = 3);
    addEntry(Category(name: 'Lottery', description: '', type: CategoryType.none)..id.value = 4);
    addEntry(Category(name: 'Mortgage', description: '', type: CategoryType.expense)..id.value = 5);
    addEntry(Category(name: 'Saving', description: '', type: CategoryType.income)..id.value = 6);
    addEntry(Category(name: 'Bills', description: '', type: CategoryType.expense)..id.value = 7);
    addEntry(Category(name: 'Taxes', description: '', type: CategoryType.expense)..id.value = 8);
    addEntry(Category(name: 'School', description: '', type: CategoryType.expense)..id.value = 9);
  }

  @override
  void onAllDataLoaded() {
    for (final Category category in getList()) {
      category.count.value = 0;
      category.runningBalance.value = 0;
    }

    for (final Transaction t in Data().transactions.getList()) {
      final Category? item = get(t.categoryId.value);
      if (item != null) {
        item.count.value++;
        item.runningBalance.value += t.amount.value;
      }
    }
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }
}
