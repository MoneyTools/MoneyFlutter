import 'package:money/core/controller/list_controller.dart';
import 'package:money/core/controller/selection_controller.dart';
import 'package:money/core/widgets/dialog/dialog_mutate_money_object.dart';
import 'package:money/data/models/money_objects/events/event.dart';
import 'package:money/data/models/money_objects/transactions/transaction.dart';
import 'package:money/data/storage/data/data.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/views/home/sub_views/adaptive_view/view_money_objects.dart';

class ViewEvents extends ViewForMoneyObjects {
  const ViewEvents({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewEventsState();
}

class ViewEventsState extends ViewForMoneyObjectsState {
  ViewEventsState() {
    viewId = ViewId.viewAliases;
  }

  /// add more top level action buttons
  @override
  List<Widget> getActionsButtons(final bool forInfoPanelTransactions) {
    final list = super.getActionsButtons(forInfoPanelTransactions);
    if (!forInfoPanelTransactions) {
      // Add a new Category, place this at the top of the list
      list.insert(
        0,
        buildAddItemButton(
          () {
            // add a new Event
            final Event newItem = Data().events.addNewEvent();
            updateListAndSelect(newItem.uniqueId);

            // Queue up the edit dialog
            myShowDialogAndActionsForMoneyObject(
              context: context,
              title: 'New ${getClassNameSingular()}',
              moneyObject: newItem,
              onApplyChange: () {
                setState(() {
                  /// update
                });
              },
            );
          },
          'Add new event',
        ),
      );
    }
    return list;
  }

  @override
  String getClassNamePlural() {
    return 'Events';
  }

  @override
  String getClassNameSingular() {
    return 'Event';
  }

  @override
  String getDescription() {
    return 'All your major life events';
  }

  @override
  Fields<Event> getFieldsForTable() {
    return Event.fieldsForColumnView;
  }

  @override
  Widget getInfoPanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return const Text('No chart for events');
  }

  @override
  Widget getInfoPanelViewTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final SelectionController selectionController =
        Get.put(SelectionController(getPreferenceKey('info_$settingKeySelectedListItemId')));

    return ListViewTransactions(
      listController: Get.find<ListControllerInfoPanel>(),
      columnsToInclude: <Field>[
        Transaction.fields.getFieldByName(columnIdDate),
        Transaction.fields.getFieldByName(columnIdAccount),
        Transaction.fields.getFieldByName(columnIdCategory),
        Transaction.fields.getFieldByName(columnIdMemo),
        Transaction.fields.getFieldByName(columnIdAmount),
      ],
      getList: () => getTransactions(
          // filter: (final Transaction transaction) => transaction.fieldDateTime.value == DateTime.now(),
          ),
      selectionController: selectionController,
    );
  }

  @override
  List<Event> getList({bool includeDeleted = false, bool applyFilter = true}) {
    return Data()
        .events
        .iterableList(includeDeleted: includeDeleted)
        .where(
          (instance) => applyFilter == false || isMatchingFilters(instance),
        )
        .toList();
  }
}
