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
    required final List<int> selectedItems,
    required final bool showAsNativeCurrency,
  }) {
    final Account? account = getFirstElement<Account>(selectedItems, list);
    if (account != null && account.id.value > -1) {
      bool filter(final Transaction transaction) => filterByAccountId(transaction, account.id.value);

      final List<Transaction> listOfTransactionForThisAccount = getFilteredTransactions(filter);

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
      );
    }
    return const CenterMessage(message: 'No item selected.');
  }
}
