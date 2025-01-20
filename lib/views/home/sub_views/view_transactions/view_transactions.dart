import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/helpers/string_helper.dart';
import 'package:money/core/widgets/side_panel/side_panel.dart';
import 'package:money/data/models/money_objects/transactions/transaction.dart';
import 'package:money/data/storage/data/data.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/transactions/list_view_transaction_splits.dart';
import 'package:money/views/home/sub_views/adaptive_view/view_money_objects.dart';
import 'package:money/views/home/sub_views/money_object_card.dart';
import 'package:money/views/home/sub_views/view_transfers/transfer_sender_receiver.dart';

/// ViewTransactions is a widget that displays a list of financial transactions.
///
/// This widget extends [ViewForMoneyObjects] and is responsible for rendering
/// a view of transactions with various features such as filtering, sorting,
/// and displaying transaction details.
///
/// Key features:
/// - Displays a list of transactions with customizable views
/// - Supports multi-selection of transactions
/// - Provides pivot options for filtering transactions (Incomes, Expenses, All)
/// - Calculates and displays running balances for transactions
/// - Allows navigation to related views (e.g., Accounts, Categories)
///
/// The [startingBalance] parameter can be used to set an initial balance
/// for the transaction list.

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
  List<Widget> getActionsButtons(final bool forSidePanelTransactions) {
    final list = super.getActionsButtons(forSidePanelTransactions);

    if (!forSidePanelTransactions && getFirstSelectedItem() != null) {
      final transaction = getFirstSelectedItem() as Transaction?;

      // this can go last
      list.add(
        buildJumpToButton(
          [
            // Account
            MenuEntry.toAccounts(accountId: transaction?.fieldAccountId.value ?? -1),

            // Category
            MenuEntry(
              icon: ViewId.viewCategories.getIconData(),
              title: 'Switch to Categories',
              onPressed: () {
                final transaction = getFirstSelectedItem() as Transaction?;
                if (transaction != null) {
                  // Preselect the Category of this Transaction
                  PreferenceController.to.jumpToView(
                    viewId: ViewId.viewCategories,
                    selectedId: transaction.fieldCategoryId.value,
                    textFilter: '',
                    columnFilters: null,
                  );
                }
              },
            ),

            // Payee
            MenuEntry(
              icon: ViewId.viewPayees.getIconData(),
              title: 'Switch to Payees',
              onPressed: () {
                final transaction = getFirstSelectedItem() as Transaction?;
                if (transaction != null) {
                  // Preselect the Payee of this Transaction
                  PreferenceController.to.jumpToView(
                    viewId: ViewId.viewPayees,
                    selectedId: transaction.fieldPayee.value,
                    textFilter: '',
                    columnFilters: null,
                  );
                }
              },
            ),
            // Search Payee
            MenuEntry(
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
  SidePanelSupport getSidePanelSupport() {
    return SidePanelSupport(
      onDetails: getSidePanelViewDetails,
      onChart: _getSidePanelViewChart,
      onTransactions: _getSidePanelViewTransactions,
    );
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

  Widget _getSidePanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final Map<String, num> tallyPerCategory = <String, num>{};

    getList().forEach((final Transaction transaction) {
      final num value = transaction.fieldAmount.value.toDouble();
      final int categoryId = transaction.fieldCategoryId.value;
      dynamic category = Data().categories.get(categoryId);
      category ??= Data().categories.unknown;
      final parentCategory = Data().categories.getTopAncestor(category!);

      // Update the map or add a new entry
      tallyPerCategory.update(
        parentCategory.name,
        (final num total) => total + value,
        ifAbsent: () => value,
      );
    });

    final List<PairXYY> list = <PairXYY>[];
    tallyPerCategory.forEach((final String key, final num value) {
      list.add(PairXYY(key, value));
    });

    list.sort((final PairXYY a, final PairXYY b) => a.yValue1.compareTo(b.yValue1));

    return Chart(
      list: list,
    );
  }

  Widget _getSidePanelViewTransactions({
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
          transaction: transaction,
        );
      }

      if (transaction.isTransfer) {
        return TransferSenderReceiver(transfer: transaction.instanceOfTransfer!);
      } else {
        final investment = Data().investments.get(transaction.uniqueId);
        if (investment != null) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: MoneyObjectCard(
              title: 'Investment',
              moneyObject: investment,
            ),
          );
        }
      }
    }
    return const CenterMessage(message: 'No related transactions');
  }
}
