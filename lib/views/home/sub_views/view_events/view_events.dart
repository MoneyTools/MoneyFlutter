import 'package:fl_chart/fl_chart.dart';
import 'package:money/core/controller/list_controller.dart';
import 'package:money/core/controller/selection_controller.dart';
import 'package:money/core/widgets/charts/my_line_chart.dart';
import 'package:money/core/widgets/dialog/dialog_mutate_money_object.dart';
import 'package:money/core/widgets/side_panel/side_panel.dart';
import 'package:money/data/models/chart_event.dart';
import 'package:money/data/models/money_objects/categories/category.dart';
import 'package:money/data/models/money_objects/events/event.dart';
import 'package:money/data/models/money_objects/transactions/transactions.dart';
import 'package:money/data/storage/data/data.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/views/home/sub_views/adaptive_view/view_money_objects.dart';
import 'package:money/views/home/sub_views/view_stocks/stock_chart.dart';

class ViewEvents extends ViewForMoneyObjects {
  const ViewEvents({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewEventsState();
}

class ViewEventsState extends ViewForMoneyObjectsState {
  ViewEventsState() {
    viewId = ViewId.viewAliases;
  }

  late final SidePanelSupport _sidePanelSupport = SidePanelSupport(
    onDetails: getSidePanelViewDetails,
    onChart: _getSidePanelViewChart,
    onTransactions: _getSidePanelViewTransactions,
  );

  /// add more top level action buttons
  @override
  List<Widget> getActionsButtons(final bool forSidePanelTransactions) {
    final list = super.getActionsButtons(forSidePanelTransactions);
    if (!forSidePanelTransactions) {
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
  List<Event> getList({bool includeDeleted = false, bool applyFilter = true}) {
    return Data()
        .events
        .iterableList(includeDeleted: includeDeleted)
        .where(
          (instance) => applyFilter == false || isMatchingFilters(instance),
        )
        .toList();
  }

  @override
  SidePanelSupport getSidePanelSupport() {
    return _sidePanelSupport;
  }

  Widget _getSidePanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    // get net worth over time
    final transactionsWithoutTransfers =
        Data().transactions.iterableList(includeDeleted: true).where((t) => t.isTransfer == false).toList();

    List<FlSpot> tmpDataPointsWithNetWorth = Transactions.cumulateTransactionPerYearMonth(transactionsWithoutTransfers);

    const marginLeft = 80.0;
    const marginBottom = 50.0;

    // get the events
    final List<ChartEvent> milestoneTransactions = [];

    for (final Event event in getList()) {
      final Category? category = Data().categories.get(event.fieldCategoryId.value);
      milestoneTransactions.add(
        ChartEvent(
          date: event.fieldDateBegin.value!,
          amount: 0,
          quantity: 1,
          colorBasedOnQuantity: false, // use Amount
          description: event.fieldName.value,
          color: category == null ? Colors.blue : category.getColorOrAncestorsColor(),
        ),
      );
    }

    // sort by ascending date
    milestoneTransactions.sort((a, b) => a.date.compareTo(b.date));

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: marginLeft, bottom: marginBottom),
          child: CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: PaintActivities(
              activities: milestoneTransactions,
              minX: tmpDataPointsWithNetWorth.first.x,
              maxX: tmpDataPointsWithNetWorth.last.x,
            ),
          ),
        ),
        MyLineChart(
          dataPoints: tmpDataPointsWithNetWorth,
          showDots: false,
        ),
      ],
    );
  }

  Widget _getSidePanelViewTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final SelectionController selectionController =
        Get.put(SelectionController(getPreferenceKey(settingKeySidePanel + settingKeySelectedListItemId)));

    return ListViewTransactions(
      listController: Get.find<ListControllerSidePanel>(),
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
}
