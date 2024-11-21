import 'package:money/core/controller/list_controller.dart';
import 'package:money/core/controller/selection_controller.dart';
import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/widgets/side_panel/side_panel.dart';
import 'package:money/data/models/money_objects/aliases/alias.dart';
import 'package:money/data/models/money_objects/transactions/transaction.dart';
import 'package:money/data/storage/data/data.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/views/home/sub_views/adaptive_view/view_money_objects.dart';

class ViewAliases extends ViewForMoneyObjects {
  const ViewAliases({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewAliasesState();
}

class ViewAliasesState extends ViewForMoneyObjectsState {
  ViewAliasesState() {
    viewId = ViewId.viewAliases;
  }

  late final SidePanelSupport _sidePanelSupport = SidePanelSupport(
    onDetails: getSidePanelViewDetails,
    onTransactions: getSidePanelViewTransactions,
  );

  @override
  String getClassNamePlural() {
    return 'Aliases';
  }

  @override
  String getClassNameSingular() {
    return 'Alias';
  }

  @override
  String getDescription() {
    return 'Payee aliases.';
  }

  @override
  Fields<Alias> getFieldsForTable() {
    return Alias.fieldsForColumnView;
  }

  @override
  List<Alias> getList({bool includeDeleted = false, bool applyFilter = true}) {
    return Data()
        .aliases
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

  Widget getSidePanelViewTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final SelectionController selectionController =
        Get.put(SelectionController(getPreferenceKey(settingKeySidePanel + settingKeySelectedListItemId)));

    final Alias? alias = getMoneyObjectFromFirstSelectedId<Alias>(selectedIds, list);
    if (alias != null && alias.fieldId.value > -1) {
      return ListViewTransactions(
        key: Key(alias.uniqueId.toString()),
        listController: Get.find<ListControllerSidePanel>(),
        columnsToInclude: <Field>[
          Transaction.fields.getFieldByName(columnIdDate),
          Transaction.fields.getFieldByName(columnIdAccount),
          Transaction.fields.getFieldByName(columnIdCategory),
          Transaction.fields.getFieldByName(columnIdMemo),
          Transaction.fields.getFieldByName(columnIdAmount),
        ],
        getList: () => getTransactions(
          flattenSplits: true,
          filter: (final Transaction transaction) => transaction.fieldPayee.value == alias.fieldPayeeId.value,
        ),
        selectionController: selectionController,
      );
    }
    return CenterMessage.noTransaction();
  }
}
