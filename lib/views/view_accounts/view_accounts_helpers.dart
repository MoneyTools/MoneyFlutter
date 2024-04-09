part of 'view_accounts.dart';

extension ViewAccountsHelpers on ViewAccountsState {
  double getTotalBalanceOfAccounts(final List<AccountType> types) {
    double total = 0.0;
    Data()
        .accounts
        .activeAccount(types)
        .forEach((final Account x) => total += x.balanceNormalized.valueFromInstance(x));
    return total;
  }

  bool filterByAccountId(final Transaction t, final num accountId) {
    return t.accountId.value == accountId;
  }

  List<AccountType> getSelectedAccountType() {
    if (_selectedPivot[0]) {
      return getSelectedAccountTypesByIndex(0);
    }

    if (_selectedPivot[1]) {
      return getSelectedAccountTypesByIndex(1);
    }

    if (_selectedPivot[2]) {
      return getSelectedAccountTypesByIndex(2);
    }

    if (_selectedPivot[3]) {
      return getSelectedAccountTypesByIndex(3);
    }
    return getSelectedAccountTypesByIndex(-1);
  }

  List<AccountType> getSelectedAccountTypesByIndex(final index) {
    switch (index) {
      case 0:
        return <AccountType>[AccountType.checking, AccountType.savings];

      case 1:
        return <AccountType>[AccountType.investment, AccountType.retirement];

      case 2:
        return <AccountType>[AccountType.credit, AccountType.creditLine];

      case 3:
        return <AccountType>[AccountType.asset, AccountType.cash, AccountType.loan];
      default: // all
        return <AccountType>[];
    }
  }

  Widget renderToggles() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: ToggleButtons(
          direction: Axis.horizontal,
          onPressed: (final int index) {
            // ignore: invalid_use_of_protected_member
            setState(() {
              for (int i = 0; i < _selectedPivot.length; i++) {
                _selectedPivot[i] = i == index;
              }
              list = getList();
              clearSelection();
            });
          },
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 100.0,
          ),
          isSelected: _selectedPivot,
          children: pivots,
        ));
  }
}
