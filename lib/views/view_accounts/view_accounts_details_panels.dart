part of 'view_accounts.dart';

extension ViewAccountsDetailsPanels on ViewAccountsState {
  /// Details panels Chart panel for Accounts
  Widget _getSubViewContentForChart(final List<int> selectedIds) {
    final List<PairXY> listOfPairXY = <PairXY>[];

    if (selectedIds.length == 1) {
      final Account? account = getFirstSelectedItemFromSelectedList(selectedIds) as Account?;
      if (account == null) {
        // this should not happen
        return const Text('Error account is null');
      }

      account.maxBalancePerYears.forEach((key, value) {
        listOfPairXY.add(PairXY(key.toString(), value));
      });
      listOfPairXY.sort((a, b) => compareAsciiLowerCase(a.xText, b.xText));

      return Chart(
        key: Key(selectedIds.toString()),
        list: listOfPairXY.take(100).toList(),
        variableNameHorizontal: 'Year',
        variableNameVertical: 'FBar',
      );
    } else {
      for (final MoneyObject item in getList()) {
        final Account account = item as Account;
        if (account.isOpen) {
          listOfPairXY.add(PairXY(account.name.value, account.balance.value));
        }
      }

      listOfPairXY.sort((final PairXY a, final PairXY b) => (b.yValue.abs() - a.yValue.abs()).toInt());

      return Chart(
        key: Key(selectedIds.toString()),
        list: listOfPairXY.take(10).toList(),
        variableNameHorizontal: 'Account',
        variableNameVertical: 'Balance',
      );
    }
  }

  // Details Panel for Transactions
  Widget _getSubViewContentForTransactions({
    required final Account account,
    required final bool showAsNativeCurrency,
  }) {
    int sortFieldIndex = 0;
    bool sortAscending = true;
    int selectedItemIndex = 0;

    final MyJson? viewSetting = Settings().views[perfDomainAccounts];
    if (viewSetting != null) {
      sortFieldIndex = viewSetting.getInt(prefSortBy, 0);
      sortAscending = viewSetting.getBool(prefSortAscending, true);
      selectedItemIndex = viewSetting.getInt(prefSelectedListItemId, -1);
    }

    final FieldDefinitions columnsToDisplay = <Field>[
      Transaction.fields.getFieldByName(columnIdDate),
      Transaction.fields.getFieldByName(columnIdPayee),
      Transaction.fields.getFieldByName(columnIdCategory),
      Transaction.fields.getFieldByName(columnIdStatus),
      Transaction.fields.getFieldByName(showAsNativeCurrency ? columnIdAmount : columnIdAmountNormalized),
      Transaction.fields.getFieldByName(showAsNativeCurrency ? columnIdBalance : columnIdBalanceNormalized),
    ];

    return ListViewTransactions(
        key: Key('${account.id.value}_currency_${showAsNativeCurrency}_version${Data().version}'),
        columnsToInclude: columnsToDisplay,
        getList: () {
          return getTransactions(filter: (Transaction transaction) {
            return filterByAccountId(transaction, account.id.value);
          });
        },
        sortFieldIndex: sortFieldIndex,
        sortAscending: sortAscending,
        selectedItemIndex: selectedItemIndex,
        onUserChoiceChanged: (int sortByFieldIndex, bool sortAscending, int selectedId) {
          // keep track of user choice
          sortFieldIndex = sortByFieldIndex;
          sortAscending = sortAscending;
          selectedId = selectedId;

          // Save user choices
          Settings().views[perfDomainAccounts] = <String, dynamic>{
            prefSortBy: sortByFieldIndex,
            prefSortAscending: sortAscending,
            prefSelectedListItemId: selectedId,
          };
        });
  }
}
