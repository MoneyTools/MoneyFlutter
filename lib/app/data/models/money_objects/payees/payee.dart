import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/money_widget.dart';
import 'package:money/app/data/models/fields/fields.dart';
import 'package:money/app/data/models/money_objects/money_object.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_item_card.dart';

export 'package:money/app/data/models/money_objects/money_object.dart';

/*
  SQLite table definition

  0|Id|INT|0||1
  1|Name|nvarchar(255)|1||0
 */
class Payee extends MoneyObject {
  Payee() {
    buildFieldsAsWidgetForSmallScreen = () => MyListItemAsCard(
          leftTopAsString: name.value,
          rightTopAsWidget: MoneyWidget(amountModel: sum.value, asTile: true),
          rightBottomAsString: getAmountAsShorthandText(count.value),
        );
  }

  factory Payee.fromJson(final MyJson row) {
    return Payee();
  }
  static final _fields = Fields<Payee>();

  static Fields<Payee> get fields {
    if (_fields.isEmpty) {
      final tmp = Payee.fromJson({});
      _fields.setDefinitions([
        tmp.id,
        tmp.name,
        tmp.categoriesAsText,
        tmp.count,
        tmp.sum,
      ]);
    }
    return _fields;
  }

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  @override
  String getRepresentation() {
    return name.value;
  }

  // 0
  FieldId id = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as Payee).uniqueId,
  );

  // 1
  FieldString name = FieldString(
    importance: 1,
    name: 'Name',
    serializeName: 'Name',
    getValueForDisplay: (final MoneyObject instance) => (instance as Payee).name.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Payee).name.value,
    setValue: (final MoneyObject instance, dynamic value) => (instance as Payee).name.value = value as String,
  );

  FieldString categoriesAsText = FieldString(
    importance: 2,
    name: 'Categories',
    getValueForDisplay: (final MoneyObject instance) => (instance as Payee).getCategoriesAsString(),
  );

  FieldQuantity count = FieldQuantity(
    importance: 98,
    name: 'Transactions',
    columnWidth: ColumnWidth.small,
    getValueForDisplay: (final MoneyObject instance) => (instance as Payee).count.value,
  );

  FieldMoney sum = FieldMoney(
    importance: 99,
    name: 'Sum',
    getValueForDisplay: (final MoneyObject instance) => (instance as Payee).sum.value,
  );

  Set<String> categories = {};

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  static String getName(final Payee? payee) {
    return payee == null ? '' : payee.name.value;
  }

  String getCategoriesAsString() {
    if (categories.isEmpty) {
      return '';
    }

    if (categories.length == 1) {
      return categories.first;
    }
    if (categories.length == 2) {
      return categories.join('; ');
    }
    return '${getIntAsText(categories.length)} categories';
  }
}
