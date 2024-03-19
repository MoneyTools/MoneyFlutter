import 'package:money/helpers/list_helper.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/categories/category.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

class Categories extends MoneyObjects<Category> {
  @override
  Category instanceFromSqlite(final MyJson row) {
    return Category.fromJson(row);
  }

  static int idOfSplitCategory = -1;

  List<Category> getListSorted() {
    final list = iterableList().toList();
    list.sort((a, b) => sortByString(a.name.value, b.name.value, true));
    return list;
  }

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
    return iterableList().firstWhereOrNull((final Category category) => category.name.value == name);
  }

  bool isCategoryAnExpense(final int categoryId) {
    final Category? category = get(categoryId);
    if (category == null) {
      return false;
    }
    return category.type.value == CategoryType.expense;
  }

  Category getTopAncestor(final Category category) {
    if (category.parentId.value == -1) {
      return category; // this is the top
    }
    final Category? parent = get(category.parentId.value);
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
    for (final Category item in iterableList()) {
      if (item.parentId.value == parentId) {
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

      addEntry(moneyObject: category);
    }
    // TODO
    // else if (result.IsDeleted) {
    //   result.Undelete();
    // }
    return category;
  }

  Category get split {
    return getOrCreateCategory('Split', CategoryType.none);
  }

  Category get salesTax {
    return getOrCreateCategory('Taxes:Sales Tax', CategoryType.expense);
  }

  Category get interestEarned {
    return getOrCreateCategory('Savings:Interest', CategoryType.income);
  }

  Category get savings {
    return getOrCreateCategory('Savings', CategoryType.income);
  }

  Category get investmentCredit {
    return getOrCreateCategory('Investments:Credit', CategoryType.income);
  }

  Category get investmentDebit {
    return getOrCreateCategory('Investments:Debit', CategoryType.expense);
  }

  Category get investmentInterest {
    return getOrCreateCategory('Investments:Interest', CategoryType.income);
  }

  Category get investmentDividends {
    return getOrCreateCategory('Investments:Dividends', CategoryType.income);
  }

  Category get investmentTransfer {
    return getOrCreateCategory('Investments:Transfer', CategoryType.none);
  }

  Category get investmentFees {
    return getOrCreateCategory('Investments:Fees', CategoryType.expense);
  }

  Category get investmentMutualFunds {
    return getOrCreateCategory('Investments:Mutual Funds', CategoryType.expense);
  }

  Category get investmentStocks {
    return getOrCreateCategory('Investments:Stocks', CategoryType.expense);
  }

  Category get investmentOther {
    return getOrCreateCategory('Investments:Other', CategoryType.expense);
  }

  Category get investmentBonds {
    return getOrCreateCategory('Investments:Bonds', CategoryType.expense);
  }

  Category get investmentOptions {
    return getOrCreateCategory('Investments:Options', CategoryType.expense);
  }

  Category get investmentReinvest {
    return getOrCreateCategory('Investments:Reinvest', CategoryType.none);
  }

  Category get investmentLongTermCapitalGainsDistribution {
    return getOrCreateCategory('Investments:Long Term Capital Gains Distribution', CategoryType.income);
  }

  Category get investmentShortTermCapitalGainsDistribution {
    return getOrCreateCategory('Investments:Short Term Capital Gains Distribution', CategoryType.income);
  }

  Category get investmentMiscellaneous {
    return getOrCreateCategory('Investments:Miscellaneous', CategoryType.expense);
  }

  Category get transferToDeletedAccount {
    return getOrCreateCategory('Xfer to Deleted Account', CategoryType.none);
  }

  Category get transferFromDeletedAccount {
    return getOrCreateCategory('Xfer from Deleted Account', CategoryType.none);
  }

  Category get transfer {
    return getOrCreateCategory('Transfer', CategoryType.none);
  }

  Category get unknown {
    return getOrCreateCategory('Unknown', CategoryType.none);
  }

  Category get unassignedSplit {
    return getOrCreateCategory('UnassignedSplit', CategoryType.none);
  }

  @override
  void loadDemoData() {
    clear();
    addEntry(
        moneyObject:
            Category(id: 0, name: 'Paychecks', description: '', type: CategoryType.income, color: '#FFAAFFBB'));
    addEntry(
        moneyObject:
            Category(id: 1, name: 'Investment', description: '', type: CategoryType.investment, color: '#FFA1A2A3'));
    addEntry(
        moneyObject:
            Category(id: 2, name: 'Interests', description: '', type: CategoryType.income, color: '#FFFF2233'));
    addEntry(
        moneyObject: Category(id: 3, name: 'Rental', description: '', type: CategoryType.income, color: '#FF11FF33'));
    addEntry(
        moneyObject: Category(id: 4, name: 'Lottery', description: '', type: CategoryType.none, color: '#FF1122FF'));
    addEntry(
        moneyObject:
            Category(id: 5, name: 'Mortgage', description: '', type: CategoryType.expense, color: '#FFBB2233'));
    addEntry(
        moneyObject: Category(id: 6, name: 'Saving', description: '', type: CategoryType.income, color: '#FFBB2233'));
    addEntry(
        moneyObject: Category(id: 7, name: 'Bills', description: '', type: CategoryType.expense, color: '#FF11DD33'));
    addEntry(
        moneyObject: Category(id: 8, name: 'Taxes', description: '', type: CategoryType.expense, color: '#FF1122DD'));
    addEntry(moneyObject: Category(id: 9, name: 'School', description: '', type: CategoryType.expense));
  }

  @override
  void onAllDataLoaded() {
    for (final Category category in iterableList()) {
      category.count.value = 0;
      category.runningBalance.value = 0;
    }

    for (final Transaction t in Data().transactions.iterableList()) {
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
