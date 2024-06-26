part of 'view_investments.dart';

extension ViewInvestmentsDetailsPanels on ViewInvestmentsState {
  /// Details panels Chart panel for Payees
  Widget _getSubViewContentForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final List<PairXY> list = <PairXY>[];
    for (final Investment entry in getList()) {
      list.add(
        PairXY(entry.security.value.toString(), entry.originalCostBasis),
      );
    }

    return Chart(
      list: list,
      variableNameHorizontal: 'Stock',
      variableNameVertical: 'value',
    );
  }

  // Details Panel for Transactions Payees
  Widget _getSubViewContentForTransactions(final List<int> indices) {
    final Investment? instance = getMoneyObjectFromFirstSelectedId<Investment>(indices, list);
    if (instance != null) {
      final List<Transaction> list = getTransactions(
        filter: (final Transaction transaction) => transaction.uniqueId == instance.uniqueId,
      );

      return ListViewTransactions(
        key: Key(instance.uniqueId.toString()),
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
}
