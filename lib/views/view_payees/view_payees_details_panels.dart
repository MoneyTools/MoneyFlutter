part of 'view_payees.dart';

extension ViewPayeesDetailsPanels on ViewPayeesState {
  /// Details panels Chart panel for Payees
  Widget _getSubViewContentForChart(final List<int> indices) {
    final List<PairXY> list = <PairXY>[];
    for (final Payee item in getList()) {
      if (item.name != 'Transfer') {
        list.add(PairXY(item.name, item.count));
      }
    }

    list.sort((final PairXY a, final PairXY b) {
      return (b.yValue.abs() - a.yValue.abs()).toInt();
    });

    return Chart(
      key: Key(indices.toString()),
      list: list.take(10).toList(),
      variableNameHorizontal: 'Payee',
      variableNameVertical: 'Transactions',
    );
  }

  // Details Panel for Transactions Payees
  Widget _getSubViewContentForTransactions(final List<int> indices) {
    final Payee? payee = getFirstElement<Payee>(indices, list);
    if (payee != null && payee.id > -1) {
      return TableTransactions(
        key: Key(payee.id.toString()),
        columnsToInclude: const <String>[
          columnIdAccount,
          columnIdDate,
          columnIdCategory,
          columnIdMemo,
          columnIdAmount,
        ],
        getList: () => getFilteredTransactions(
          (final Transaction transaction) => transaction.payeeId == payee.id,
        ),
      );
    }
    return const Text('No transactions');
  }
}
