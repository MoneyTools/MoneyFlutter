part of 'view_categories.dart';

extension ViewCategoriesSidePanel on ViewCategoriesState {
  /// Details panels Chart panel for Categories
  Widget _getSubViewContentForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    if (selectedIds.isEmpty) {
      final Map<String, num> map = <String, num>{};

      for (final Category item in getList()) {
        if (item.fieldName.value != 'Split' && item.fieldName.value != 'Xfer to Deleted Account') {
          final Category topCategory = Data().categories.getTopAncestor(item);
          if (map[topCategory.fieldName.value] == null) {
            map[topCategory.fieldName.value] = 0;
          }
          map[topCategory.fieldName.value] = map[topCategory.fieldName.value]! + item.fieldSum.value.toDouble();
        }
      }
      final List<PairXYY> list = <PairXYY>[];
      map.forEach((final String key, final num value) {
        list.add(PairXYY(key, value));
      });

      list.sort((final PairXYY a, final PairXYY b) {
        return (b.yValue1.abs() - a.yValue1.abs()).toInt();
      });

      return Chart(
        key: Key(selectedIds.toString()),
        list: list.take(10).toList(),
      );
    } else {
      return TransactionTimelineChart(transactions: _getTransactionsFromSelectedIds(selectedIds));
    }
  }

  // Details Panel for Transactions Categories
  Widget _getSubViewContentForTransactions({required final List<int> selectedIds, required bool showAsNativeCurrency}) {
    final SelectionController selectionController = Get.put(SelectionController());

    return ListViewTransactions(
      listController: Get.find<ListControllerSidePanel>(),
      columnsToInclude: <Field<dynamic>>[
        Transaction.fields.getFieldByName(columnIdDate),
        Transaction.fields.getFieldByName(columnIdAccount),
        Transaction.fields.getFieldByName(columnIdPayee),
        Transaction.fields.getFieldByName(columnIdCategory),
        Transaction.fields.getFieldByName(columnIdMemo),
        Transaction.fields.getFieldByName(columnIdAmount),
      ],
      getList: () => _getTransactionsFromSelectedIds(selectedIds),
      selectionController: selectionController,
    );
  }
}
