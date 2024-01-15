part of 'view_accounts.dart';

extension ViewAccountsDetailsPanels on ViewAccountsState {
  /// Details panels Chart panel for Accounts
  Widget _getSubViewContentForChart(final List<int> indices) {
    final List<PairXY> list = <PairXY>[];
    for (final MoneyObject item in getList()) {
      final Account account = item as Account;
      if (account.isActive()) {
        list.add(PairXY(account.name, account.balance));
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
  Widget _getSubViewContentForTransactions(final List<int> indices) {
    final Account? account = getFirstElement<Account>(indices, list);
    if (account != null && account.id > -1) {
      filter(final Transaction transaction) => filterByAccountId(transaction, account.id);

      final List<Transaction> listOfTransactionForThisAccount = getFilteredTransactions(filter);

      return TableTransactions(
        key: Key(account.id.toString()),
        columnsToInclude: const <String>[
          columnIdDate,
          columnIdPayee,
          columnIdCategory,
          columnIdMemo,
          columnIdAmount,
        ],
        getList: () => listOfTransactionForThisAccount,
      );
    }
    return const Text('No account transactions');
  }
}