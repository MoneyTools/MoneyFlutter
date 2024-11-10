part of 'view_payees.dart';

extension ViewPayeesSidePanel on ViewPayeesState {
  /// Details panels Chart panel for Payees
  Widget _getSubViewContentForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    if (selectedIds.isEmpty) {
      final List<PairXYY> list = <PairXYY>[];
      for (final Payee item in getList()) {
        if (item.fieldName.value != 'Transfer') {
          list.add(PairXYY(item.fieldName.value, item.fieldCount.value));
        }
      }

      list.sort((final PairXYY a, final PairXYY b) {
        return (b.yValue1.abs() - a.yValue1.abs()).toInt();
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
  Widget _getSubViewContentForTransactions({required final List<int> selectedIds, required bool showAsNativeCurrency}) {
    final Payee? payee = getMoneyObjectFromFirstSelectedId<Payee>(selectedIds, list);
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
