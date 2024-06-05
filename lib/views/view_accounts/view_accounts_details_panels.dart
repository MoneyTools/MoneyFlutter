part of 'view_accounts.dart';

extension ViewAccountsDetailsPanels on ViewAccountsState {
  /// Details panels Chart panel for Accounts
  Widget _getSubViewContentForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final List<PairXY> listOfPairXY = <PairXY>[];

    if (selectedIds.length == 1) {
      final Account? account = getFirstSelectedItemFromSelectedList(selectedIds) as Account?;
      if (account == null) {
        // this should not happen
        return const Text('No account selected');
      }

      account.maxBalancePerYears.forEach((key, value) {
        double valueCurrencyChoice = showAsNativeCurrency ? value : value * account.getCurrencyRatio();

        listOfPairXY.add(PairXY(key.toString(), valueCurrencyChoice));
      });
      listOfPairXY.sort((a, b) => compareAsciiLowerCase(a.xText, b.xText));

      return Chart(
        key: Key('$selectedIds $showAsNativeCurrency'),
        list: listOfPairXY.take(100).toList(),
        variableNameHorizontal: 'Year',
        variableNameVertical: 'FBar',
        currency: showAsNativeCurrency ? account.currency.value : Constants.defaultCurrency,
      );
    } else {
      for (final MoneyObject item in getList()) {
        final Account account = item as Account;
        if (account.isOpen) {
          listOfPairXY.add(PairXY(account.name.value,
              showAsNativeCurrency ? account.balance : account.balanceNormalized.getValueForDisplay(account)));
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
    int sortFieldIndex = PreferencesHelper().getInt(getPreferenceKey('info_$settingKeySortBy')) ?? 0;
    bool sortAscending = PreferencesHelper().getBool(getPreferenceKey('info_$settingKeySortAscending')) ?? true;
    int selectedItemIndex = PreferencesHelper().getInt(getPreferenceKey('info_$settingKeySelectedListItemId')) ?? -1;

    final FieldDefinitions columnsToDisplay = <Field>[
      Transaction.fields.getFieldByName(columnIdDate),
      Transaction.fields.getFieldByName(columnIdPayee),
      Transaction.fields.getFieldByName(columnIdCategory),
      Transaction.fields.getFieldByName(columnIdStatus),
      Transaction.fields.getFieldByName(showAsNativeCurrency ? columnIdAmount : columnIdAmountNormalized),
      Transaction.fields.getFieldByName(showAsNativeCurrency ? columnIdBalance : columnIdBalanceNormalized),
    ];

    return ListViewTransactions(
        key: Key('transaction_list_currency_${showAsNativeCurrency}_version${Data().version}'),
        columnsToInclude: columnsToDisplay,
        getList: () => getTransactionForLastSelectedAccount(account),
        sortFieldIndex: sortFieldIndex,
        sortAscending: sortAscending,
        selectedItemIndex: selectedItemIndex,
        onUserChoiceChanged: (int sortByFieldIndex, bool sortAscending, final int uniqueId) {
          // keep track of user choice
          sortFieldIndex = sortByFieldIndex;
          sortAscending = sortAscending;

          // Save user choices
          PreferencesHelper().setInt(getPreferenceKey('info_$settingKeySortBy'), sortByFieldIndex);
          PreferencesHelper().setBool(getPreferenceKey('info_$settingKeySortAscending'), sortAscending);
          PreferencesHelper().setInt(getPreferenceKey('info_$settingKeySelectedListItemId'), uniqueId);
        });
  }

  List<Transaction> getTransactionForLastSelectedAccount(final Account account) {
    return getTransactions(filter: (Transaction transaction) {
      return filterByAccountId(transaction, account.uniqueId);
    });
  }
}
