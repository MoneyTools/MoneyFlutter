import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/ranges.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/transactions/list_view_transaction_splits.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/view_money_objects.dart';
import 'package:money/app/modules/home/sub_views/money_object_card.dart';
import 'package:money/app/modules/home/sub_views/view_transfers/transfer_sender_receiver.dart';

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

  final List<Widget> pivots = <Widget>[];
  final TextStyle styleHeader = const TextStyle(fontWeight: FontWeight.w600, fontSize: 20);

  bool balanceDone = false;

  final List<bool> _selectedPivot = <bool>[false, false, true];

  @override
  List<Widget> getActionsButtons(final bool forInfoPanelTransactions) {
    final list = super.getActionsButtons(forInfoPanelTransactions);

    if (!forInfoPanelTransactions && getFirstSelectedItem() != null) {
      final transaction = getFirstSelectedItem() as Transaction?;

      // this can go last
      list.add(
        buildJumpToButton(
          [
            // Account
            InternalViewSwitching.toAccounts(accountId: transaction?.fieldAccountId.value ?? -1),

            // Category
            InternalViewSwitching(
              icon: ViewId.viewCategories.getIconData(),
              title: 'Switch to Categories',
              onPressed: () {
                final transaction = getFirstSelectedItem() as Transaction?;
                if (transaction != null) {
                  // Preselect the Category of this Transactio
                  PreferenceController.to.jumpToView(
                    viewId: ViewId.viewCategories,
                    selectedId: transaction.fieldCategoryId.value,
                    columnFilter: [],
                    textFilter: '',
                  );
                }
              },
            ),

            // Payee
            InternalViewSwitching(
              icon: ViewId.viewPayees.getIconData(),
              title: 'Switch to Payees',
              onPressed: () {
                final transaction = getFirstSelectedItem() as Transaction?;
                if (transaction != null) {
                  // Preselect the Payee of this Transaction
                  PreferenceController.to.jumpToView(
                    viewId: ViewId.viewPayees,
                    selectedId: transaction.fieldPayee.value,
                    columnFilter: [],
                    textFilter: '',
                  );
                }
              },
            ),
            // Search Payee
            InternalViewSwitching(
              icon: Icons.person_search_outlined,
              title: 'Search for Payee',
              onPressed: () {
                final transaction = getFirstSelectedItem() as Transaction?;
                if (transaction != null) {
                  launchGoogleSearch(transaction.getPayeeOrTransferCaption());
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
  Fields<Transaction> getFieldsForTable() {
    return Transaction.fieldsForColumnView;
  }

  @override
  Widget getInfoPanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final Map<String, num> tallyPerMonths = <String, num>{};

    final DateRange timePeriod = DateRange(
      min: DateTime.now().subtract(const Duration(days: 356)).startOfDay,
      max: DateTime.now().endOfDay,
    );

    getList().forEach((final Transaction transaction) {
      transaction;

      if (timePeriod.isBetweenEqual(transaction.fieldDateTime.value)) {
        final num value = transaction.fieldAmount.value.toDouble();

        final DateTime date = transaction.fieldDateTime.value!;
        // Format the date as year-month string (e.g., '2023-11')
        final String yearMonth = '${date.year}-${date.month.toString().padLeft(2, '0')}';

        // Update the map or add a new entry
        tallyPerMonths.update(
          yearMonth,
          (final num total) => total + value,
          ifAbsent: () => value,
        );
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
    final Transaction? transaction = getFirstSelectedItem() as Transaction?;

    //
    // If the category of this transaction is a Split then list the details of the Split
    //
    if (transaction != null) {
      if (transaction.isSplit) {
        // this is Split get the split transactions
        return ListViewTransactionSplits(
          key: Key('split_transactions ${transaction.uniqueId}'),
          getList: () {
            return Data()
                .splits
                .iterableList()
                .where(
                  (final MoneySplit s) => s.fieldTransactionId.value == transaction.fieldId.value,
                )
                .toList();
          },
        );
      }

      if (transaction.isTransfer) {
        return TransferSenderReceiver(transfer: transaction.transferInstance!);
      } else {
        final investment = Data().investments.get(transaction.uniqueId);
        if (investment != null) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: MoneyObjectCard(
              title: 'Investent',
              moneyObject: investment,
            ),
          );
        }
      }
    }
    return const CenterMessage(message: 'No related transactions');
  }

  @override
  List<Transaction> getList({
    bool includeDeleted = false,
    bool applyFilter = true,
  }) {
    final List<Transaction> list = Data()
        .transactions
        .iterableList(includeDeleted: includeDeleted)
        .where(
          (final Transaction transaction) =>
              isMatchingIncomeExpense(transaction) && (applyFilter == false || isMatchingFilters(transaction)),
        )
        .toList();

    if (!balanceDone) {
      list.sort(
        (final Transaction a, final Transaction b) => sortByDate(a.fieldDateTime.value, b.fieldDateTime.value),
      );

      double runningNativeBalance = 0.0;

      for (Transaction transaction in list) {
        runningNativeBalance += transaction.fieldAmount.value.toDouble();
        transaction.balance = runningNativeBalance;
      }

      balanceDone = true;
    }
    return list;
  }

  @override
  String getViewId() {
    return Data().transactions.getTypeName();
  }

  @override
  void initState() {
    super.initState();

    pivots.add(
      ThreePartLabel(
        text1: 'Incomes',
        small: true,
        isVertical: true,
        text2: getIntAsText(
          Data()
              .transactions
              .iterableList()
              .where(
                (final Transaction element) => element.fieldAmount.value.toDouble() > 0,
              )
              .length,
        ),
      ),
    );
    pivots.add(
      ThreePartLabel(
        text1: 'Expenses',
        small: true,
        isVertical: true,
        text2: getIntAsText(
          Data()
              .transactions
              .iterableList()
              .where(
                (final Transaction element) => element.fieldAmount.value.toDouble() < 0,
              )
              .length,
        ),
      ),
    );
    pivots.add(
      ThreePartLabel(
        text1: 'All',
        small: true,
        isVertical: true,
        text2: getIntAsText(Data().transactions.iterableList().length),
      ),
    );
  }

  bool isMatchingIncomeExpense(final Transaction transaction) {
    if (_selectedPivot[2]) {
      return true;
    }

    // Expenses
    if (_selectedPivot[1]) {
      return transaction.fieldAmount.value.toDouble() < 0;
    }

    // Incomes
    if (_selectedPivot[0]) {
      return transaction.fieldAmount.value.toDouble() > 0;
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
      ),
    );
  }
}
