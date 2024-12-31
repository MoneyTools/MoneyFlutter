import 'package:money/core/helpers/json_helper.dart';
import 'package:money/core/helpers/string_helper.dart';
import 'package:money/core/widgets/money_widget.dart';
import 'package:money/data/models/money_objects/money_object.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/list_item_card.dart';

export 'package:money/data/models/money_objects/money_object.dart';

/*
  SQLite table definition

  0|Id|INT|0||1
  1|Name|nvarchar(255)|1||0
 */
class Payee extends MoneyObject {
  Payee();

  factory Payee.fromJson(final MyJson row) {
    return Payee();
  }

  Set<String> categories = {};
  FieldString fieldCategoriesAsText = FieldString(
    name: 'Categories',
    getValueForDisplay: (final MoneyObject instance) => (instance as Payee).getCategoriesAsString(),
  );

  FieldInt fieldCount = FieldInt(
    name: 'Transactions',
    columnWidth: ColumnWidth.small,
    getValueForDisplay: (final MoneyObject instance) => (instance as Payee).fieldCount.value,
  );

  // 0 - ID
  FieldId fieldId = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as Payee).uniqueId,
  );

  // 1
  FieldString fieldName = FieldString(
    name: 'Name',
    serializeName: 'Name',
    getValueForDisplay: (final MoneyObject instance) => (instance as Payee).fieldName.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Payee).fieldName.value,
    setValue: (final MoneyObject instance, dynamic value) => (instance as Payee).fieldName.value = value as String,
  );

  FieldMoney fieldSum = FieldMoney(
    name: 'Sum',
    getValueForDisplay: (final MoneyObject instance) => (instance as Payee).fieldSum.value,
  );

  @override
  Widget buildFieldsAsWidgetForSmallScreen() {
    return MyListItemAsCard(
      leftTopAsString: fieldName.value,
      rightTopAsWidget: MoneyWidget(amountModel: fieldSum.value, asTile: true),
      rightBottomAsString: getAmountAsShorthandText(fieldCount.value),
    );
  }

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  @override
  String getRepresentation() {
    return fieldName.value;
  }

  @override
  int get uniqueId => fieldId.value;

  @override
  set uniqueId(value) => fieldId.value = value;

  static final _fields = Fields<Payee>();

  static Fields<Payee> get fields {
    if (_fields.isEmpty) {
      final tmp = Payee.fromJson({});
      _fields.setDefinitions([
        tmp.fieldId,
        tmp.fieldName,
        tmp.fieldCategoriesAsText,
        tmp.fieldCount,
        tmp.fieldSum,
      ]);
    }
    return _fields;
  }

  /// Returns a [Fields] instance that defines the fields to be displayed in a column view for a [Payee] object.
  /// The fields included are:
  /// - [Payee.fieldName]: The name of the payee.
  /// - [Payee.fieldCategoriesAsText]: The categories associated with the payee, as a string.
  /// - [Payee.fieldCount]: The count or number of occurrences for the payee.
  /// - [Payee.fieldSum]: The total sum or amount associated with the payee.
  static Fields<Payee> get fieldsForColumnView {
    final tmp = Payee.fromJson({});
    return Fields<Payee>()
      ..setDefinitions([
        tmp.fieldName,
        tmp.fieldCategoriesAsText,
        tmp.fieldCount,
        tmp.fieldSum,
      ]);
  }

  /// Returns a string representation of the categories associated with the payee.
  /// If there are no categories, an empty string is returned.
  /// If there is one category, that category is returned.
  /// If there are two categories, they are joined with a semicolon and space.
  /// If there are more than two categories, the number of categories is returned as a string.
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

  /// Returns the name of the [Payee] object, or an empty string if the [Payee] is null.
  static String getName(final Payee? payee) {
    return payee == null ? '' : payee.fieldName.value;
  }
}
