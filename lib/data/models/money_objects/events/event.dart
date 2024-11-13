// ignore_for_file: unnecessary_this

import 'package:money/core/helpers/date_helper.dart';
import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/core/widgets/picker_edit_box_date.dart';
import 'package:money/core/widgets/picker_panel.dart';
import 'package:money/core/widgets/suggestion_approval.dart';
import 'package:money/core/widgets/token_text.dart';
import 'package:money/data/storage/data/data.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/list_item_card.dart';
import 'package:money/views/home/sub_views/view_categories/picker_category.dart';

class Event extends MoneyObject {
  Event({
    required final int id,
    required final String name,
    final int categoryId = -1,
    required final DateTime? dateBegin,
    required final DateTime? dateEnd,
    required final String people,
    required final String memo,
  }) {
    this.fieldId.value = id;
    this.fieldName.value = name;
    this.fieldCategoryId.value = categoryId;
    this.fieldDateBegin.value = dateBegin;
    this.fieldDateEnd.value = dateEnd;
    this.fieldPeople.value = people;
    this.fieldMemo.value = memo;
  }

  /// Constructor from a SQLite row
  factory Event.fromJson(final MyJson row) {
    return Event(
      id: row.getInt('Id', -1),
      name: row.getString('Name'),
      categoryId: row.getInt('Category', -1),
      dateBegin: row.getDate('Begin'),
      dateEnd: row.getDate('End'),
      people: row.getString('People'),
      memo: row.getString('Memo'),
    );
  }

  /// Category Id
  FieldInt fieldCategoryId = FieldInt(
    type: FieldType.widget,
    align: TextAlign.left,
    footer: FooterType.count,
    name: 'Category',
    serializeName: 'Category',
    defaultValue: -1,
    getValueForDisplay: (final MoneyObject instance) {
      final Event event = (instance as Event);
      if (event.fieldCategoryId.value == -1) {
        return SuggestionApproval(
          onApproved: event.possibleMatchingCategoryId == -1
              ? null
              : () {
                  // record the change
                  changeCategory(event, event.possibleMatchingCategoryId);
                },
          onChooseCategory: (final BuildContext context) {
            event.possibleMatchingCategoryId = -1;
            showPopupSelection(
              title: 'Category',
              context: context,
              items: Data().categories.getCategoriesAsStrings(),
              selectedItem: '',
              onSelected: (final String text) {
                final selectedCategory = Data().categories.getByName(text);
                if (selectedCategory != null) {
                  // record the change
                  changeCategory(event, selectedCategory.uniqueId);
                }
              },
            );
          },
          child: Data().categories.getCategoryWidget(
                event.possibleMatchingCategoryId,
              ),
        );
      } else {
        return Data().categories.getCategoryWidget(event.fieldCategoryId.value);
      }
    },
    getValueForReading: (final MoneyObject instance) => (instance as Event).categoryName,
    getValueForSerialization: (final MoneyObject instance) => (instance as Event).fieldCategoryId.value,
    setValue: (final MoneyObject instance, dynamic newValue) =>
        (instance as Event).fieldCategoryId.value = newValue as int,
    getEditWidget: (final MoneyObject instance, Function(bool wasModified) onEdited) {
      return pickerCategory(
        key: const Key('key_pick_category'),
        itemSelected: Data().categories.get((instance as Event).fieldCategoryId.value),
        onSelected: (Category? newCategory) {
          if (newCategory != null) {
            instance.fieldCategoryId.value = newCategory.uniqueId;
            // notify container
            onEdited(true);
          }
        },
      );
    },
  );

  /// Date Begin
  FieldDate fieldDateBegin = _createDateField(
    'Begins',
    'Begin',
    (event) => event.fieldDateBegin,
  );

  /// Date End
  FieldDate fieldDateEnd = _createDateField(
    'Ends',
    'End',
    (event) => event.fieldDateEnd,
  );

  FieldInt fieldDuration = FieldInt(
    name: 'Duration',
    align: TextAlign.center,
    columnWidth: ColumnWidth.small,
    getValueForDisplay: (final MoneyObject instance) => (instance as Event).durationAsString,
  );

  /// ID
  FieldId fieldId = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as Event).uniqueId,
  );

  /// Memo
  FieldString fieldMemo = FieldString(
    name: 'Memo',
    serializeName: 'Memo',
    columnWidth: ColumnWidth.large,
    getValueForDisplay: (final MoneyObject instance) => (instance as Event).fieldMemo.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Event).fieldMemo.value,
  );

  /// Name
  FieldString fieldName = FieldString(
    name: 'Name',
    serializeName: 'Name',
    type: FieldType.widget,
    getValueForDisplay: (final MoneyObject instance) => TokenText((instance as Event).eventName),
    getValueForSerialization: (final MoneyObject instance) => (instance as Event).fieldName.value,
    setValue: (final MoneyObject instance, dynamic value) => (instance as Event).fieldName.value = value,
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) => sortByString(
      (a as Event).fieldName.value,
      (b as Event).fieldName.value,
      ascending,
    ),
  );

  /// People
  FieldString fieldPeople = FieldString(
    name: 'People',
    serializeName: 'People',
    getValueForDisplay: (final MoneyObject instance) => (instance as Event).fieldPeople.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Event).fieldPeople.value,
  );

  int possibleMatchingCategoryId = -1;

  @override
  Widget buildFieldsAsWidgetForSmallScreen() {
    return MyListItemAsCard(
      leftTopAsString: 'Begin',
      rightTopAsString: 'End',
      rightBottomAsString: 'Memo',
    );
  }

  @override
  String getRepresentation() {
    return eventName;
  }

  @override
  int get uniqueId => fieldId.value;

  @override
  set uniqueId(value) => fieldId.value = value;

  String get categoryName => Data().categories.getNameFromId(this.fieldCategoryId.value);

  static void changeCategory(Event item, final int categoryId) {
    // record the change
    item.stashValueBeforeEditing();

    // Make change
    item.fieldCategoryId.value = categoryId;
    item.possibleMatchingCategoryId = -1;

    // inform of changes
    Data().notifyMutationChanged(
      mutation: MutationType.changed,
      moneyObject: item,
      recalculateBalances: true,
    );
  }

  String get durationAsString =>
      DateRange(min: fieldDateBegin.value, max: fieldDateEnd.value ?? DateTime.now()).toStringDuration();

  String get eventName => fieldName.value.isEmpty ? 'Event $uniqueId' : fieldName.value;

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  static final Fields<Event> _fields = Fields<Event>();
  static final Fields<Event> _fieldsColumView = Fields<Event>();

  static Fields<Event> get fields {
    if (_fields.isEmpty) {
      final tmpInstance = Event.fromJson({});
      _fields.setDefinitions([
        tmpInstance.fieldId,
        tmpInstance.fieldName,
        tmpInstance.fieldCategoryId,
        tmpInstance.fieldDateBegin,
        tmpInstance.fieldDateEnd,
        tmpInstance.fieldDuration,
        tmpInstance.fieldPeople,
        tmpInstance.fieldMemo,
      ]);
    }
    return _fields;
  }

  static Fields<Event> get fieldsForColumnView {
    if (_fieldsColumView.isEmpty) {
      final tmpInstance = Event.fromJson({});
      _fieldsColumView.setDefinitions([
        tmpInstance.fieldName,
        tmpInstance.fieldCategoryId,
        tmpInstance.fieldDateBegin,
        tmpInstance.fieldDateEnd,
        tmpInstance.fieldDuration,
        tmpInstance.fieldPeople,
        tmpInstance.fieldMemo,
      ]);
    }
    return _fieldsColumView;
  }

  static FieldDate _createDateField(String name, String serializeName, FieldDate Function(Event) getField) {
    return FieldDate(
      name: name,
      serializeName: serializeName,
      columnWidth: ColumnWidth.small,
      getValueForDisplay: (final MoneyObject instance) => getField(instance as Event).value,
      getEditWidget: (final MoneyObject instance, Function(bool wasModified) onEdited) {
        return PickerEditBoxDate(
          key: Constants.keyDatePicker,
          initialValue: dateToDateTimeString(getField(instance as Event).value),
          onChanged: (String? newDateSelected) {
            if (newDateSelected != null) {
              getField(instance).value = attemptToGetDateFromText(newDateSelected);
              onEdited(true);
            }
          },
        );
      },
      setValue: (MoneyObject instance, dynamic newValue) =>
          getField(instance as Event).value = attemptToGetDateFromText(newValue),
      getValueForSerialization: (final MoneyObject instance) =>
          dateToIso8601OrDefaultString(getField(instance as Event).value),
    );
  }
}
