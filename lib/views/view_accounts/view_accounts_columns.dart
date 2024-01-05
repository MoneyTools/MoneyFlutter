part of 'view_accounts.dart';

extension ViewAccountsColumns on ViewAccountsState {
  ColumnDefinitions<Account> _getColumnDefinitionsForTable() {
    final List<ColumnDefinition<Account>> fieldDefinitions = <ColumnDefinition<Account>>[
      ColumnDefinition<Account>(
        name: 'Name',
        type: ColumnType.text,
        align: TextAlign.left,
        value: (final int index) {
          return list[index].name;
        },
        sort: (final Account a, final Account b, final bool sortAscending) {
          return sortByString(
            a.name,
            b.name,
            sortAscending,
          );
        },
      ),
      ColumnDefinition<Account>(
        name: 'Type',
        type: ColumnType.text,
        align: TextAlign.center,
        value: (final int index) {
          return list[index].getTypeAsText();
        },
        sort: (final Account a, final Account b, final bool sortAscending) {
          return sortByString(
            a.getTypeAsText(),
            b.getTypeAsText(),
            sortAscending,
          );
        },
      ),
      ColumnDefinition<Account>(
        name: 'Count',
        type: ColumnType.numeric,
        align: TextAlign.right,
        value: (final int index) {
          return list[index].count;
        },
        sort: (final Account a, final Account b, final bool sortAscending) {
          return sortByValue(
            a.count,
            b.count,
            sortAscending,
          );
        },
      ),
      ColumnDefinition<Account>(
        name: 'Balance',
        type: ColumnType.amount,
        align: TextAlign.right,
        value: (final int index) {
          return list[index].balance;
        },
        sort: (final Account a, final Account b, final bool sortAscending) {
          return sortByValue(
            a.balance,
            b.balance,
            sortAscending,
          );
        },
      ),
    ];

    if (Settings().includeClosedAccounts) {
      fieldDefinitions.add(
        ColumnDefinition<Account>(
          name: 'Status',
          type: ColumnType.text,
          align: TextAlign.center,
          value: (final int index) {
            return list[index].isClosed() ? 'Closed' : 'Active';
          },
          sort: (final Account a, final Account b, final bool sortAscending) {
            return sortByString(
              a.isClosed().toString(),
              b.isClosed().toString(),
              sortAscending,
            );
          },
        ),
      );
    }

    return ColumnDefinitions<Account>(list: fieldDefinitions);
  }
}
