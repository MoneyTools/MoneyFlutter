part of 'view_payees.dart';

extension ViewPayeesColumns on ViewPayeesState {
  FieldDefinitions<Payee> _getFieldDefinitionsForTable() {
    return FieldDefinitions<Payee>(list: <FieldDefinition<Payee>>[
      FieldDefinition<Payee>(
        name: 'Name',
        type: FieldType.text,
        align: TextAlign.left,
        value: (final int index) {
          return list[index].name;
        },
        sort: (final Payee a, final Payee b, final bool sortAscending) {
          return sortByString(a.name, b.name, sortAscending);
        },
      ),
      FieldDefinition<Payee>(
        name: 'Count',
        type: FieldType.numeric,
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
      FieldDefinition<Payee>(
        name: 'Balance',
        type: FieldType.amount,
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
