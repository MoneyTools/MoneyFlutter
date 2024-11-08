part of 'view_payees.dart';

extension ViewPayeesSidePanel on ViewPayeesState {
  /// Details panels Chart panel for Payees
  Widget _getSubViewContentForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    if (selectedIds.isEmpty) {
      final List<PairXY> list = <PairXY>[];
      for (final Payee item in getList()) {
        if (item.fieldName.value != 'Transfer') {
          list.add(PairXY(item.fieldName.value, item.fieldCount.value));
        }
      }

      list.sort((final PairXY a, final PairXY b) {
        return (b.yValue.abs() - a.yValue.abs()).toInt();
      });

      return Chart(
        key: Key(selectedIds.toString()),
        list: list.take(10).toList(),
      );
    }

    final List<Transaction> flatTransactions = Transactions.flatTransactions(
      Data().transactions.iterableList().where((t) => t.fieldPayee.value == selectedIds.first),
    );

    return TransactionTimelineChart(transactions: flatTransactions);
  }

  // Details Panel for Transactions Payees
  Widget _getSubViewContentForTransactions(final List<int> indices) {
    final Payee? payee = getMoneyObjectFromFirstSelectedId<Payee>(indices, list);
    if (payee != null && payee.fieldId.value > -1) {
      final SelectionController selectionController = Get.put(SelectionController());
      return ListViewTransactions(
        key: Key(payee.uniqueId.toString()),
        listController: Get.find<ListControllerSidePanel>(),
        columnsToInclude: <Field>[
          Transaction.fields.getFieldByName(columnIdDate),
          Transaction.fields.getFieldByName(columnIdAccount),
          Transaction.fields.getFieldByName(columnIdCategory),
          Transaction.fields.getFieldByName(columnIdMemo),
          Transaction.fields.getFieldByName(columnIdAmount),
        ],
        getList: () => getTransactions(
          flattenSplits: true,
          filter: (final Transaction transaction) => transaction.fieldPayee.value == payee.fieldId.value,
        ),
        selectionController: selectionController,
      );
    }
    return CenterMessage.noTransaction();
  }
}
