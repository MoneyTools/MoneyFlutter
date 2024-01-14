import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/money_object.dart';

/*
  the SQLite table definition

  0|Id|INT|0||1
  1|Name|nvarchar(255)|1||0

 */
class Payee extends MoneyObject {
  String name;
  num count = 0;
  double balance = 0.00;

  Payee({
    required super.id,
    required this.name,
  });

  static FieldDefinitions<Payee> getFieldDefinitions() {
    final FieldDefinitions<Payee> fields = FieldDefinitions<Payee>(definitions: <FieldDefinition<Payee>>[
      FieldDefinition<Payee>(
        useAsColumn: false,
        name: 'Id',
        serializeName: 'id',
        type: FieldType.text,
        align: TextAlign.left,
        valueFromInstance: (final Payee entity) => entity.id,
        sort: (final Payee a, final Payee b, final bool sortAscending) {
          return sortByValue(a.id, b.id, sortAscending);
        },
      ),
      FieldDefinition<Payee>(
        name: 'Name',
        serializeName: 'name',
        type: FieldType.text,
        align: TextAlign.left,
        valueFromInstance: (final Payee entity) => entity.name,
        sort: (final Payee a, final Payee b, final bool sortAscending) {
          return sortByString(a.name, b.name, sortAscending);
        },
      ),
      FieldDefinition<Payee>(
        name: 'Count',
        type: FieldType.numeric,
        align: TextAlign.right,
        valueFromInstance: (final Payee entity) => entity.count,
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
        valueFromInstance: (final Payee entity) => entity.balance,
        sort: (final Payee a, final Payee b, final bool sortAscending) {
          return sortByValue(
            a.balance,
            b.balance,
            sortAscending,
          );
        },
      ),
    ]);
    return fields;
  }

  static getCsvHeader() {
    final List<String> headerList = <String>[];
    getFieldDefinitions().definitions.forEach((final FieldDefinition<Payee> field) {
      if (field.serializeName != null) {
        headerList.add(field.serializeName!);
      }
    });
    return headerList.join(',');
  }
}
