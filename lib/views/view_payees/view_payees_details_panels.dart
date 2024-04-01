part of 'view_payees.dart';

extension ViewPayeesDetailsPanels on ViewPayeesState {
  /// Details panels Chart panel for Payees
  Widget _getSubViewContentForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final List<PairXY> list = <PairXY>[];
    for (final Payee item in getList()) {
      if (item.name.value != 'Transfer') {
        list.add(PairXY(item.name.value, item.count.value));
      }
    }

    list.sort((final PairXY a, final PairXY b) {
      return (b.yValue.abs() - a.yValue.abs()).toInt();
    });

    return Chart(
      key: Key(selectedIds.toString()),
      list: list.take(10).toList(),
      variableNameHorizontal: 'Payee',
      variableNameVertical: 'Transactions',
    );
  }

  // Details Panel for Transactions Payees
  Widget _getSubViewContentForTransactions(final List<int> indices) {
    final Payee? payee = getMoneyObjectFromFirstSelectedId<Payee>(indices, list);
    if (payee != null && payee.id.value > -1) {
      return ListViewTransactions(
        key: Key(payee.uniqueId.toString()),
        columnsToInclude: <Field>[
          Transaction.fields.getFieldByName(columnIdAccount),
          Transaction.fields.getFieldByName(columnIdDate),
          Transaction.fields.getFieldByName(columnIdCategory),
          Transaction.fields.getFieldByName(columnIdMemo),
          Transaction.fields.getFieldByName(columnIdMemo),
          Transaction.fields.getFieldByName(columnIdAmount),
        ],
        getList: () => getTransactions(
          filter: (final Transaction transaction) => transaction.payee.value == payee.id.value,
        ),
      );
    }
    return CenterMessage.noTransaction();
  }
}
