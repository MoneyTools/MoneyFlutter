import 'package:money/helpers/string_helper.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/widgets/list_view/list_item_card.dart';

/*
  SQLite table definition

  0|Id|INT|0||1
  1|Name|nvarchar(255)|1||0
 */
class Payee extends MoneyObject {
  @override
  int get uniqueId => id.value;
  @override
  set uniqueId(value) => id.value = value;

  // 0
  FieldId<Payee> id = FieldId<Payee>(
    valueForSerialization: (final Payee instance) => instance.uniqueId,
  );

  // 1
  Field<Payee, String> name = Field<Payee, String>(
    importance: 1,
    name: 'Name',
    serializeName: 'Name',
    defaultValue: '',
    valueFromInstance: (final Payee instance) => instance.name.value,
    valueForSerialization: (final Payee instance) => instance.name.value,
  );

  Field<Payee, int> count = DeclareNoSerialized<Payee, int>(
    type: FieldType.numeric,
    name: 'Count',
    defaultValue: 0,
    align: TextAlign.right,
    valueFromInstance: (final Payee instance) => instance.count.value,
    valueForSerialization: (final Payee instance) => instance.count.value,
  );

  Field<Payee, double> balance = DeclareNoSerialized<Payee, double>(
    type: FieldType.amount,
    name: 'Balance',
    defaultValue: 0,
    align: TextAlign.right,
    valueFromInstance: (final Payee instance) => instance.balance.value,
    valueForSerialization: (final Payee instance) => instance.balance.value,
  );

  Payee() {
    buildFieldsAsWidgetForSmallScreen = () => MyListItemAsCard(
          leftTopAsString: name.value,
          rightTopAsString: Currency.getCurrencyText(balance.value),
          rightBottomAsString: getNumberAsShorthandText(count.value),
        );
  }

  static String getName(final Payee? payee) {
    return payee == null ? '' : payee.name.value;
  }
}
