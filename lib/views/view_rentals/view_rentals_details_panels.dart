part of 'view_rentals.dart';

extension ViewRentalsDetailsPanels on ViewRentalsState {
  /// Details panels Chart panel for Payees
  Widget _getSubViewContentForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    if (selectedIds.isEmpty) {
      final List<PairXY> list = <PairXY>[];
      for (final RentBuilding entry in getList()) {
        list.add(PairXY(entry.name.value, entry.profit.value));
      }
      return Chart(
        list: list,
        variableNameHorizontal: 'Rental',
        variableNameVertical: 'Profit',
      );
    }

    RentBuilding? rental = getFirstSelectedItem() as RentBuilding?;
    if (rental != null) {
      // show PnL for the selected rental property, per year
      List<Widget> pnlCards = [];

      for (int year = rental.dateRangeOfOperation.min!.year; year <= rental.dateRangeOfOperation.max!.year; year++) {
        final pnl = rental.pnlOverYears[year];
        if (pnl == null) {
          pnlCards.add(Text(year.toString()));
        } else {
          pnlCards.add(RentalPnLCard(pnl: pnl));
        }
      }
      pnlCards.add(RentalPnLCard(
        pnl: rental.lifeTimePnL,
        customTitle: 'Life Time P&L',
      ));

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          children: pnlCards,
        ),
      );
    }
    return const Text('No Rental property selected');
  }

  void getPnLOverYears(RentBuilding rental) {
    for (final transaction in Data().transactions.iterableList()) {
      if (rental.categoryForIncomeTreeIds.contains(transaction.categoryId.value)) {}
    }
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
          Transaction.fields.getFieldByName(columnIdDate),
          Transaction.fields.getFieldByName(columnIdAccount),
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
