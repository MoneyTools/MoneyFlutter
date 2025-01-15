import 'package:money/core/helpers/ranges.dart';
import 'package:money/data/models/money_objects/categories/category.dart';
import 'package:money/data/models/money_objects/transactions/transaction.dart';
import 'package:money/data/storage/data/data.dart';

class RecurringExpenses {
  RecurringExpenses({
    required this.category,
    required this.sumOfAllTransactions,
    this.sumPerMonth = 0,
    this.sumIncome = 0,
    this.sumExpense = 0,
    this.sumBudget = 0,
    this.dates,
  });

  final Category category;
  final double sumOfAllTransactions;

  double sumBudget = 0;
  double sumExpense = 0;
  double sumIncome = 0;
  double sumPerMonth = 0;

  DateRange? dates = DateRange();

  static List<RecurringExpenses> getBudgetedTransactions(
    final int minYear,
    final int maxYear,
    final bool onlyNonZeroBudget,
    final List<CategoryType> categoryTypes,
  ) {
    List<RecurringExpenses> items = [];

    final Iterable<Category> recurringCategories = Data().categories.iterableList().where((c) {
      if (!categoryTypes.contains(c.fieldType.value)) {
        return false;
      }
      if (onlyNonZeroBudget && c.fieldBudget.value.toDouble() == 0) {
        return false;
      }
      return true;
    });

    for (final Category category in recurringCategories) {
      List<Category> listOfDescendants = [category]; // include this Category

      category.getDescendants(listOfDescendants);

      // get all transactions meeting the request of date and type
      bool whereClause(Transaction t) {
        return listOfDescendants.contains(t.category) &&
            isBetweenOrEqual(t.fieldDateTime.value!.year, minYear, maxYear);
      }

      final List<Transaction> flatTransactions = Data().transactions.getListFlattenSplits(whereClause: whereClause);

      double totalForAllTimeForThisCategory = 0;
      DateRange dateRangeOfTransactions = DateRange();

      for (final Transaction transaction in flatTransactions) {
        totalForAllTimeForThisCategory += transaction.fieldAmount.value.toDouble();
        dateRangeOfTransactions.inflate(transaction.fieldDateTime.value);
      }

      final double sumByMonthForTheCategory = totalForAllTimeForThisCategory / dateRangeOfTransactions.durationInMonths;

      final RecurringExpenses item = RecurringExpenses(
        category: category,
        sumOfAllTransactions: totalForAllTimeForThisCategory,
        sumPerMonth: sumByMonthForTheCategory,
        sumBudget: 0,
      );
      item.dates = dateRangeOfTransactions;

      items.add(item);
    }

    items.sort(
      (a, b) => a.sumOfAllTransactions.compareTo(b.sumOfAllTransactions),
    );
    return items;
  }

  static Map<int, RecurringExpenses> getSumByIncomeExpenseByYears(
    int minYear,
    int maxYear,
    bool includeAssetAccounts,
  ) {
    Map<int, RecurringExpenses> yearMap = {};

    final List<Transaction> flatTransactions = Data().transactions.getListFlattenSplits(
          whereClause: (t) =>
              t.category != null &&
              isBetweenOrEqual(t.fieldDateTime.value!.year, minYear, maxYear) &&
              (includeAssetAccounts || !t.isAssetAccount),
        );

    for (final Transaction t in flatTransactions) {
      if (t.category != null) {
        final int year = t.fieldDateTime.value!.year;
        if (!yearMap.containsKey(year)) {
          yearMap[year] = RecurringExpenses(category: t.category!, sumOfAllTransactions: 0);
        }
        yearMap[year]!.sumBudget += t.category!.fieldBudget.value.toDouble();

        final double amount = t.fieldAmount.value.toDouble();
        if (t.category!.isExpense) {
          yearMap[year]!.sumExpense += amount;
        }
        if (t.category!.isIncome) {
          yearMap[year]!.sumIncome += amount;
        }
      }
    }

    return yearMap;
  }
}
