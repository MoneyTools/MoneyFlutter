part of 'view_accounts.dart';

extension ViewAccountsDetailsPanels on ViewAccountsState {
  /// Details panels Chart panel for Accounts
  Widget _getSubViewContentForChart(final List<int> indices) {
    final List<PairXY> list = <PairXY>[];

    for (final MoneyObject item in getList()) {
      final Account account = item as Account;
      if (account.isOpen()) {
        list.add(PairXY(account.name.value, account.balance.value));
      }
    }

    list.sort((final PairXY a, final PairXY b) => (b.yValue.abs() - a.yValue.abs()).toInt());

    return Chart(
      key: Key(indices.toString()),
      list: list.take(10).toList(),
      variableNameHorizontal: 'Account',
      variableNameVertical: 'Balance',
    );
  }

  // Details Panel for Transactions
  Widget _getSubViewContentForTransactions({
    required final Account account,
    required final bool showAsNativeCurrency,
  }) {
    bool filter(final Transaction transaction) => filterByAccountId(transaction, account.id.value);

    final List<Transaction> listOfTransactionForThisAccount = getFilteredTransactions(filter);

    int sortField = 0;
    bool sortAscending = true;
    int selectedItemIndex = 0;

    final MyJson? viewSetting = Settings().views['accountDetailsTransactions'];
    if (viewSetting != null) {
      sortField = viewSetting.getInt(prefSortBy, 0);
      sortAscending = viewSetting.getBool(prefSortAscending, true);
      selectedItemIndex = viewSetting.getInt(prefSelectedListItemIndex, 0);
    }

    return ListViewTransactions(
        key: Key('${account.id.value}_currency_$showAsNativeCurrency'),
        columnsToInclude: <String>[
          columnIdDate,
          columnIdPayee,
          columnIdCategory,
          columnIdStatus,
          showAsNativeCurrency ? columnIdAmount : columnIdAmountNormalized,
          showAsNativeCurrency ? columnIdBalance : columnIdBalanceNormalized,
        ],
        getList: () => listOfTransactionForThisAccount,
        defaultSortingField: sortField,
        sortAscending: sortAscending,
        selectedItemIndex: selectedItemIndex,
        sortOrderChanged: (int sortByFieldIndex, bool sortAscending, int selectedItemIndex) {
          Settings().views['accountDetailsTransactions'] = <String, dynamic>{
            prefSortBy: sortByFieldIndex,
            prefSortAscending: sortAscending,
            prefSelectedListItemIndex: selectedItemIndex,
          };
        });
  }
}
