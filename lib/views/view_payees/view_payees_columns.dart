part of 'view_payees.dart';

extension ViewPayeesColumns on ViewPayeesState {
  ColumnDefinitions<Payee> _getColumnDefinitionsForTable() {
    return ColumnDefinitions<Payee>(list: <ColumnDefinition<Payee>>[
      ColumnDefinition<Payee>(
        name: 'Name',
        type: ColumnType.text,
        align: TextAlign.left,
        value: (final int index) {
          return list[index].name;
        },
        sort: (final Payee a, final Payee b, final bool sortAscending) {
          return sortByString(a.name, b.name, sortAscending);
        },
      ),
      ColumnDefinition<Payee>(
        name: 'Count',
        type: ColumnType.numeric,
        align: TextAlign.right,
        value: (final int index) {
          return list[index].count;
        },
        sort: (final Payee a, final Payee b, final bool sortAscending) {
          return sortByValue(
            a.count,
            b.count,
            sortAscending,
          );
        },
      ),
      ColumnDefinition<Payee>(
        name: 'Balance',
        type: ColumnType.amount,
        align: TextAlign.right,
        value: (final int index) {
          return list[index].balance;
        },
        sort: (final Payee a, final Payee b, final bool sortAscending) {
          return sortByValue(
            a.balance,
            b.balance,
            sortAscending,
          );
        },
      ),
    ]);
  }
}
