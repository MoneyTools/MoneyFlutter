import 'package:money/helpers/string_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/widgets/list_view/list_item_card.dart';

export 'package:money/models/money_objects/money_object.dart';

/*
  SQLite table definition

  0|Id|INT|0||1
  1|Name|nvarchar(255)|1||0
 */
class Payee extends MoneyObject {
  static Fields<Payee>? fields;

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  @override
  String getRepresentation() {
    // TODO
    return name.value;
  }

  // 0
  FieldId id = FieldId(
    valueForSerialization: (final MoneyObject instance) => (instance as Payee).uniqueId,
  );

  // 1
  Field<String> name = Field<String>(
    importance: 1,
    name: 'Name',
    serializeName: 'Name',
    defaultValue: '',
    valueFromInstance: (final MoneyObject instance) => (instance as Payee).name.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Payee).name.value,
  );

  FieldInt count = FieldInt(
    name: 'Transactions',
    columnWidth: ColumnWidth.small,
    valueFromInstance: (final MoneyObject instance) => (instance as Payee).count.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Payee).count.value,
  );

  FieldAmount sum = FieldAmount(
    name: 'Sum',
    valueFromInstance: (final MoneyObject instance) => (instance as Payee).sum.value,
  );

  Payee() {
    fields ??= Fields<Payee>(definitions: [
      id,
      name,
      count,
      sum,
    ]);
    // Also stash the definition in the instance for fast retrieval later
    fieldDefinitions = fields!.definitions;

    buildFieldsAsWidgetForSmallScreen = () => MyListItemAsCard(
          leftTopAsString: name.value,
          rightTopAsString: Currency.getAmountAsStringUsingCurrency(sum.value),
          rightBottomAsString: getAmountAsShorthandText(count.value),
        );
  }

  static String getName(final Payee? payee) {
    return payee == null ? '' : payee.name.value;
  }
}
