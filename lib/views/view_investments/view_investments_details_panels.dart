part of 'view_investments.dart';

extension ViewRentalsDetailsPanels on ViewInvestmentsState {
  /// Details panels Chart panel for Payees
  Widget _getSubViewContentForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final List<PairXY> list = <PairXY>[];
    for (final Investment entry in getList()) {
      list.add(PairXY(entry.security.value.toString(), entry.originalCostBasis));
    }

    return Chart(
      list: list,
      variableNameHorizontal: 'Rental',
      variableNameVertical: 'Profit',
    );
  }

  // Details Panel for Transactions Payees
  Widget _getSubViewContentForTransactions(final List<int> indices) {
    final RentBuilding? rental = getMoneyObjectFromFirstSelectedId<RentBuilding>(indices, list);
    if (rental != null) {
      final List<Transaction> list = getTransactions(
        filter: (final Transaction transaction) => filterByRentalCategories(
          transaction,
          rental,
        ),
      );

      return ListViewTransactions(
        key: Key(rental.uniqueId.toString()),
        columnsToInclude: <Field>[
          Transaction.fields.getFieldByName(columnIdAccount),
          Transaction.fields.getFieldByName(columnIdDate),
          Transaction.fields.getFieldByName(columnIdPayee),
          Transaction.fields.getFieldByName(columnIdCategory),
          Transaction.fields.getFieldByName(columnIdMemo),
          Transaction.fields.getFieldByName(columnIdAmount),
        ],
        getList: () => list,
      );
    }
    return CenterMessage.noTransaction();
  }

  bool filterByRentalCategories(final Transaction t, final RentBuilding rental) {
    final num categoryIdToMatch = t.categoryId.value;

    if (categoryIdToMatch == Data().categories.splitCategoryId()) {
      final List<Split> splits = Data().splits.getListFromTransactionId(t.id.value);

      for (final Split split in splits) {
        if (isMatchingCategories(split.categoryId, rental)) {
          return true;
        }
      }
      return false;
    }

    return isMatchingCategories(categoryIdToMatch, rental);
  }

  bool isMatchingCategories(final num categoryIdToMatch, final RentBuilding rental) {
    Data().categories.getTreeIds(rental.categoryForIncome.value);

    return rental.categoryForIncomeTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForManagementTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForRepairsTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForMaintenanceTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForTaxesTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForInterestTreeIds.contains(categoryIdToMatch);
  }
}
