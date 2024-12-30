import 'package:money/data/models/money_objects/categories/category.dart';
import 'package:money/data/models/money_objects/transactions/transaction.dart';
import 'package:money/data/storage/data/data.dart';

class RecurringExpenses {
  RecurringExpenses(
    this.category,
    this.sum, {
    this.sumIncome = 0,
    this.sumExpense = 0,
    this.sumBudget = 0,
  });

  final Category category;
  final double sum;

  double sumBudget = 0;
  double sumExpense = 0;
  double sumIncome = 0;

  static List<RecurringExpenses> getRecurringItems(int minYear, int maxYear) {
    List<RecurringExpenses> items = [];
    final recurringCategories =
        Data().categories.iterableList().where((c) => c.fieldType.value == CategoryType.recurringExpense);

    for (final Category category in recurringCategories) {
      // get all transactions meeting the request of date and type
      bool whereClause(Transaction t) {
        return t.category == category && isBetweenOrEqual(t.fieldDateTime.value!.year, minYear, maxYear);
      }

      final List<Transaction> flatTransactions = Data().transactions.getListFlattenSplits(whereClause: whereClause);
      final double sumOfTransactionsForCategory =
          flatTransactions.fold<double>(0, (p, e) => p + e.fieldAmount.value.toDouble());

      final RecurringExpenses item = RecurringExpenses(category, sumOfTransactionsForCategory, sumBudget: 1.12);
      items.add(item);
    }
    items.sort(
      (a, b) => a.sum.compareTo(b.sum),
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
          yearMap[year] = RecurringExpenses(t.category!, 0);
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
