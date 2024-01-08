part of 'view_categories.dart';

extension ViewCategoriesDetailsPanels on ViewCategoriesState {
  /// Details panels Chart panel for Categories
  Widget _getSubViewContentForChart(final List<int> indices) {
    final Map<String, num> map = <String, num>{};

    for (final Category item in getList()) {
      if (item.name != 'Split' && item.name != 'Xfer to Deleted Account') {
        final Category topCategory = Categories.getTopAncestor(item);
        if (map[topCategory.name] == null) {
          map[topCategory.name] = 0;
        }
        map[topCategory.name] = map[topCategory.name]! + item.balance;
      }
    }
    final List<PairXY> list = <PairXY>[];
    map.forEach((final String key, final num value) {
      list.add(PairXY(key, value));
    });

    list.sort((final PairXY a, final PairXY b) {
      return (b.yValue.abs() - a.yValue.abs()).toInt();
    });

    return Chart(
      key: Key(indices.toString()),
      list: list.take(8).toList(),
      variableNameHorizontal: 'Category',
      variableNameVertical: 'Balance',
    );
  }

  // Details Panel for Transactions Categories
  Widget _getSubViewContentForTransactions(final List<int> indices) {
    final Category? category = getFirstElement<Category>(indices, list);
    if (category != null && category.id > -1) {
      return TableTransactions(
        key: Key(category.id.toString()),
        columnsToInclude: const <String>[
          columnIdAccount,
          columnIdDate,
          columnIdPayee,
          columnIdMemo,
          columnIdAmount,
        ],
        getList: () => getFilteredTransactions(
          (final Transaction transaction) => transaction.categoryId == category.id,
        ),
      );
    }
    return const Text('No transactions');
  }
}
