part of 'view_accounts.dart';

extension ViewAccountsHelpers on ViewAccountsState {
  double getTotalBalanceOfAccounts(final List<AccountType> types) {
    double total = 0.0;
    Accounts.activeAccount(types).forEach((final Account x) => total += x.balance);
    return total;
  }

  bool filterByAccountId(final Transaction t, final num accountId) {
    return t.accountId == accountId;
  }

  List<AccountType> getSelectedAccountType() {
    if (_selectedPivot[0]) {
      return <AccountType>[AccountType.checking, AccountType.savings];
    }

    if (_selectedPivot[1]) {
      return <AccountType>[AccountType.credit];
    }

    if (_selectedPivot[2]) {
      return <AccountType>[AccountType.asset];
    }
    return <AccountType>[]; // all
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
              selectedItems.value.clear();
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
