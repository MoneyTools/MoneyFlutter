import 'package:flutter/material.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/columns/footer_widgets.dart';
import 'package:money/app/core/widgets/dialog/dialog_button.dart';
import 'package:money/app/core/widgets/widgets.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/date_range.dart';
import 'package:money/app/data/models/fields/fields.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/transactions/list_view_transaction_splits.dart';
import 'package:money/app/modules/home/sub_views/view_money_objects.dart';

class ViewTransactions extends ViewForMoneyObjects {

  const ViewTransactions({
    super.key,
    this.startingBalance = 0.00,
  });
  final double startingBalance;

  @override
  State<ViewForMoneyObjects> createState() => ViewTransactionsState();
}

class ViewTransactionsState extends ViewForMoneyObjectsState {

  ViewTransactionsState() {
    viewId = ViewId.viewTransactions;
    supportsMultiSelection = true;
  }
  final TextStyle styleHeader = const TextStyle(fontWeight: FontWeight.w600, fontSize: 20);
  final List<Widget> pivots = <Widget>[];
  final List<bool> _selectedPivot = <bool>[false, false, true];
  bool balanceDone = false;

  // Footer related
  final DateRange _footerColumnDate = DateRange();
  double _footerRunningBalanceUSD = 0.0;

  @override
  void initState() {
    super.initState();

    pivots.add(ThreePartLabel(
        text1: 'Incomes',
        small: true,
        isVertical: true,
        text2: getIntAsText(Data()
            .transactions
            .iterableList()
            .where((final Transaction element) => element.amount.value.toDouble() > 0)
            .length)));
    pivots.add(ThreePartLabel(
        text1: 'Expenses',
        small: true,
        isVertical: true,
        text2: getIntAsText(Data()
            .transactions
            .iterableList()
            .where((final Transaction element) => element.amount.value.toDouble() < 0)
            .length)));
    pivots.add(ThreePartLabel(
        text1: 'All', small: true, isVertical: true, text2: getIntAsText(Data().transactions.iterableList().length)));
  }

  @override
  String getClassNamePlural() {
    return 'Transactions';
  }

  @override
  String getClassNameSingular() {
    return 'Transaction';
  }

  @override
  String getDescription() {
    return 'Details actions of your accounts.';
  }

  @override
  String getViewId() {
    return Data().transactions.getTypeName();
  }

  @override
  List<Widget> getActionsButtons(final bool forInfoPanelTransactions) {
    final list = super.getActionsButtons(forInfoPanelTransactions);

    if (!forInfoPanelTransactions && getFirstSelectedItem() != null) {
      // this can go last
      list.add(
        buildJumpToButton(
          [
            // Account
            InternalViewSwitching(
              ViewId.viewAccounts.getIconData(),
              'Switch to Accounts',
              () {
                final transaction = getFirstSelectedItem() as Transaction?;
                if (transaction != null) {
                  // Preselect the Account of this Transaction

                  PreferenceController.to.setInt(
                    ViewId.viewAccounts.getViewPreferenceId(settingKeySelectedListItemId),
                    transaction.accountId.value,
                  );

                  PreferenceController.to.setView(ViewId.viewAccounts);
                }
              },
            ),

            // Category
            InternalViewSwitching(
              ViewId.viewCategories.getIconData(),
              'Switch to Categories',
              () {
                final transaction = getFirstSelectedItem() as Transaction?;
                if (transaction != null) {
                  // Preselect the Category of this Transaction
                  PreferenceController.to.setInt(
                      ViewId.viewCategories.getViewPreferenceId(
                        settingKeySelectedListItemId,
                      ),
                      transaction.categoryId.value);
                  PreferenceController.to.setView(ViewId.viewCategories);
                }
              },
            ),

            // Payee
            InternalViewSwitching(
              ViewId.viewPayees.getIconData(),
              'Switch to Payees',
              () {
                final transaction = getFirstSelectedItem() as Transaction?;
                if (transaction != null) {
                  // Preselect the Payee of this Transaction
                  PreferenceController.to.setInt(
                    ViewId.viewPayees.getViewPreferenceId(settingKeySelectedListItemId),
                    transaction.payee.value,
                  );
                  PreferenceController.to.setView(ViewId.viewPayees);
                }
              },
            ),
          ],
        ),
      );
    }

    return list;
  }

  @override
  Fields<Transaction> getFieldsForTable() {
    return Transaction.fields;
  }

  @override
  Widget? getColumnFooterWidget(final Field field) {
    switch (field.name) {
      case 'Date':
        return getFooterForDateRange(_footerColumnDate);
      case 'Balance(USD)':
        return getFooterForAmount(_footerRunningBalanceUSD);
      default:
        return null;
    }
  }

  @override
  List<Transaction> getList({bool includeDeleted = false, bool applyFilter = true}) {
    final List<Transaction> list = Data()
        .transactions
        .iterableList(includeDeleted: includeDeleted)
        .where((final Transaction transaction) =>
            isMatchingIncomeExpense(transaction) && (applyFilter == false || isMatchingFilters(transaction)))
        .toList();

    if (!balanceDone) {
      list.sort((final Transaction a, final Transaction b) => sortByDate(a.dateTime.value, b.dateTime.value));

      double runningNativeBalance = 0.0;
      _footerRunningBalanceUSD = 0.0;
      _footerColumnDate.clear();

      for (Transaction transaction in list) {
        _footerColumnDate.inflate(transaction.dateTime.value);
        runningNativeBalance += transaction.amount.value.toDouble();

        transaction.balance = runningNativeBalance;

        // only the last item is used
        _footerRunningBalanceUSD =
            (transaction.balanceNormalized.getValueForDisplay(transaction) as MoneyModel).toDouble();
      }

      balanceDone = true;
    }
    return list;
  }

  bool isMatchingIncomeExpense(final Transaction transaction) {
    if (_selectedPivot[2]) {
      return true;
    }

    // Expenses
    if (_selectedPivot[1]) {
      return transaction.amount.value.toDouble() < 0;
    }

    // Incomes
    if (_selectedPivot[0]) {
      return transaction.amount.value.toDouble() > 0;
    }
    return false;
  }

  Widget renderToggles() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: ToggleButtons(
          direction: Axis.horizontal,
          onPressed: (final int index) {
            setState(() {
              for (int i = 0; i < _selectedPivot.length; i++) {
                _selectedPivot[i] = i == index;
              }
              list = getList();
            });
          },
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 100.0,
          ),
          isSelected: _selectedPivot,
          children: pivots,
        ));
  }

  @override
  Widget getInfoPanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final Map<String, num> tallyPerMonths = <String, num>{};

    final DateRange timePeriod =
        DateRange(min: DateTime.now().subtract(const Duration(days: 356)).startOfDay, max: DateTime.now().endOfDay);

    getList().forEach((final Transaction transaction) {
      transaction;

      if (timePeriod.isBetweenEqual(transaction.dateTime.value)) {
        final num value = transaction.amount.value.toDouble();

        final DateTime date = transaction.dateTime.value!;
        // Format the date as year-month string (e.g., '2023-11')
        final String yearMonth = '${date.year}-${date.month.toString().padLeft(2, '0')}';

        // Update the map or add a new entry
        tallyPerMonths.update(yearMonth, (final num total) => total + value, ifAbsent: () => value);
      }
    });

    final List<PairXY> list = <PairXY>[];
    tallyPerMonths.forEach((final String key, final num value) {
      list.add(PairXY(key, value));
    });

    list.sort((final PairXY a, final PairXY b) => a.xText.compareTo(b.xText));

    return Chart(
      list: list,
      variableNameHorizontal: 'Month',
      variableNameVertical: 'Transactions',
    );
  }

  @override
  Widget getInfoPanelViewTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final Transaction? transaction = getMoneyObjectFromFirstSelectedId<Transaction>(selectedIds, list);
    //
    // If the category of this transaction is a Split then list the details of the Split
    //
    if (transaction != null && transaction.categoryId.value == Data().categories.splitCategoryId()) {
      // this is Split get the split transactions
      return ListViewTransactionSplits(
        key: Key('split_transactions ${transaction.uniqueId}'),
        getList: () {
          return Data()
              .splits
              .iterableList()
              .where((final MoneySplit s) => s.transactionId.value == transaction.id.value)
              .toList();
        },
      );
    }
    return const CenterMessage(message: 'No related transactions');
  }
}
