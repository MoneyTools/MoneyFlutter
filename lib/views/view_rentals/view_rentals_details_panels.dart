part of 'view_rentals.dart';

extension ViewRentalsDetailsPanels on ViewRentalsState {
  /// Details panels Chart panel for Payees
  Widget _getSubViewContentForChart(final List<int> indices) {
    final List<PairXY> list = <PairXY>[];
    for (final Rental entry in getList()) {
      list.add(PairXY(entry.name, entry.profit));
    }

    return Chart(
      list: list,
      variableNameHorizontal: 'Rental',
      variableNameVertical: 'Profit',
    );
  }

  // Details Panel for Transactions Payees
  Widget _getSubViewContentForTransactions(final List<int> indices) {
    final Rental? rental = getFirstElement<Rental>(indices, list);
    if (rental != null) {
      final List<Transaction> list = getFilteredTransactions(
        (final Transaction transaction) => filterByRentalCategories(
          transaction,
          rental,
        ),
      );

      return TableTransactions(
        key: Key(rental.id.toString()),
        columnsToInclude: const <String>[
          columnIdAccount,
          columnIdDate,
          columnIdPayee,
          columnIdCategory,
          columnIdMemo,
          columnIdAmount,
        ],
        getList: () => list,
      );
    }
    return const Text('No transactions');
  }

  bool filterByRentalCategories(final Transaction t, final Rental rental) {
    final num categoryIdToMatch = t.categoryId;

    if (categoryIdToMatch == Data().categories.splitCategoryId()) {
      final List<Split> splits = Splits.get(t.id);

      for (final Split split in splits) {
        if (isMatchingCategories(split.categoryId, rental)) {
          return true;
        }
      }
      return false;
    }

    return isMatchingCategories(categoryIdToMatch, rental);
  }

  bool isMatchingCategories(final num categoryIdToMatch, final Rental rental) {
    Data().categories.getTreeIds(rental.categoryForIncome);

    return rental.categoryForIncomeTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForManagementTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForRepairsTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForMaintenanceTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForTaxesTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForInterestTreeIds.contains(categoryIdToMatch);
  }
}
