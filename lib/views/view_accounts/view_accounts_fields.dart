part of 'view_accounts.dart';

extension ViewAccountsColumns on ViewAccountsState {
  FieldDefinitions<Account> _getFieldDefinitionsForTable() {
    final List<FieldDefinition<Account>> fieldDefinitions = <FieldDefinition<Account>>[
      FieldDefinition<Account>(
        name: 'Name',
        type: FieldType.text,
        align: TextAlign.left,
        valueFromList: (final int index) {
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
      FieldDefinition<Account>(
        name: 'Type',
        type: FieldType.text,
        align: TextAlign.center,
        valueFromList: (final int index) {
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
      FieldDefinition<Account>(
        name: 'Count',
        type: FieldType.numericShorthand,
        align: TextAlign.right,
        valueFromList: (final int index) {
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
      FieldDefinition<Account>(
        name: 'Balance',
        type: FieldType.amount,
        align: TextAlign.right,
        valueFromList: (final int index) {
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
        FieldDefinition<Account>(
          name: 'Status',
          type: FieldType.text,
          align: TextAlign.center,
          valueFromList: (final int index) {
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

    return FieldDefinitions<Account>(list: fieldDefinitions);
  }
}
