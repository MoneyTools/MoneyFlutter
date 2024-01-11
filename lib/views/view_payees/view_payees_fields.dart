part of 'view_payees.dart';

extension ViewPayeesColumns on ViewPayeesState {
  FieldDefinitions<Payee> _getFieldDefinitionsForTable() {
    final FieldDefinition<Payee>? fieldName = Payee.getFieldDefinitions().getFieldById('Name');
    fieldName!.valueFromList = (final int index) {
      return list[index].name;
    };

    final FieldDefinition<Payee>? fieldCount = Payee.getFieldDefinitions().getFieldById('Count');
    fieldCount!.valueFromList = (final int index) {
      return list[index].count;
    };

    final FieldDefinition<Payee>? fieldBalance = Payee.getFieldDefinitions().getFieldById('Balance');
    fieldBalance!.valueFromList = (final int index) {
      return list[index].balance;
    };

    return FieldDefinitions<Payee>(definitions: <FieldDefinition<Payee>>[
      fieldName,
      fieldCount,
      fieldBalance,
    ]);
  }
}
