import 'package:money/core/controller/list_controller.dart';
import 'package:money/core/controller/selection_controller.dart';
import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/widgets/side_panel/side_panel.dart';
import 'package:money/data/models/money_objects/payees/payee.dart';
import 'package:money/data/models/money_objects/transactions/transactions.dart';
import 'package:money/data/storage/data/data.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/transactions/transaction_timeline_chart.dart';
import 'package:money/views/home/sub_views/adaptive_view/view_money_objects.dart';
import 'package:money/views/home/sub_views/view_payees/merge_payees.dart';

part 'view_payees_side_panel.dart';

class ViewPayees extends ViewForMoneyObjects {
  const ViewPayees({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewPayeesState();
}

class ViewPayeesState extends ViewForMoneyObjectsState {
  ViewPayeesState() {
    viewId = ViewId.viewPayees;
  }

  /// add more top level action buttons
  @override
  List<Widget> getActionsButtons(final bool forSidePanelTransactions) {
    final List<Widget> list = super.getActionsButtons(forSidePanelTransactions);
    if (!forSidePanelTransactions) {
      /// Merge
      final MoneyObject? moneyObject = getFirstSelectedItem();
      if (moneyObject != null) {
        list.add(
          buildMergeButton(
            () {
              // let the user pick another Payee and merge change the transaction of the current selected payee to the destination
              final Payee payee = (moneyObject as Payee);
              showMergePayee(context, payee);
            },
          ),
        );
      }

      // this can go last
      if (getFirstSelectedItem() != null) {
        list.add(
          buildJumpToButton(
            <MenuEntry>[
              MenuEntry(
                icon: ViewId.viewTransactions.getIconData(),
                title: 'Switch to Transactions',
                onPressed: () {
                  final Payee? payee = getFirstSelectedItem() as Payee?;
                  if (payee != null) {
                    // Prepare the Transaction view to show only the selected account
                    switchViewTransactionForPayee(payee.fieldName.value);
                  }
                },
              ),
            ],
          ),
        );
      }
    }
    return list;
  }

  @override
  String getClassNamePlural() {
    return 'Payees';
  }

  @override
  String getClassNameSingular() {
    return 'Payee';
  }

  @override
  String getDescription() {
    return 'Who is getting your money.';
  }

  @override
  Fields<Payee> getFieldsForTable() {
    return Payee.fieldsForColumnView;
  }

  @override
  List<Payee> getList({bool includeDeleted = false, bool applyFilter = true}) {
    final List<Payee> list = Data()
        .payees
        .iterableList(includeDeleted: includeDeleted)
        .where(
          (Payee instance) => (applyFilter == false || isMatchingFilters(instance)),
        )
        .toList();

    return list;
  }

  @override
  SidePanelSupport getSidePanelSupport() {
    return SidePanelSupport(
      onDetails: getSidePanelViewDetails,
      onChart: _getSubViewContentForChart,
      onTransactions: _getSubViewContentForTransactions,
    );
  }

  @override
  List<MoneyObject> getSidePanelTransactions() {
    final Payee? payee = getFirstSelectedItem() as Payee?;
    if (payee != null && payee.fieldId.value > -1) {
      return getTransactions(
        filter: (final Transaction transaction) => transaction.fieldPayee.value == payee.fieldId.value,
      );
    }
    return <MoneyObject>[];
  }
}
