import 'package:money/app/controller/selection_controller.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/widgets/dialog/dialog_mutate_money_object.dart';
import 'package:money/app/data/models/money_objects/categories/category.dart';
import 'package:money/app/data/models/money_objects/currencies/currency.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/view_money_objects.dart';
import 'package:money/app/modules/home/sub_views/view_categories/merge_categories.dart';

part 'view_categories_details_panels.dart';

class ViewCategories extends ViewForMoneyObjects {
  const ViewCategories({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewCategoriesState();
}

class ViewCategoriesState extends ViewForMoneyObjectsState {
  ViewCategoriesState() {
    viewId = ViewId.viewCategories;
  }

  final List<Widget> _pivots = <Widget>[];
  final List<bool> _selectedPivot = <bool>[
    false,
    false,
    false,
    false,
    false,
    true,
  ];

  @override
  Widget buildHeader([final Widget? child]) {
    return super.buildHeader(_buildToggles());
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
            // add a new Category
            final Category? currentSelectedCategory = getFirstSelectedItem() as Category?;
            final newItem = Data().categories.addNewCategory(
                  parentId: currentSelectedCategory?.uniqueId ?? -1,
                );
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
          'Add new category',
        ),
      );

      /// Merge
      final MoneyObject? moneyObject = getFirstSelectedItem();
      if (moneyObject != null) {
        list.add(
          buildMergeButton(
            () {
              // let the user pick another Category and move the transactions of the current selected Category to the destination
              adaptiveScreenSizeDialog(
                context: context,
                title: 'Move Category',
                captionForClose: 'Cancel', // this will hide the close button
                child: MergeCategoriesTransactionsDialog(
                  categoryToMove: getFirstSelectedItem() as Category,
                ),
              );
            },
          ),
        );
      }

      // this can go last
      final Category? category = getFirstSelectedItem() as Category?;
      if (category != null) {
        list.add(
          buildJumpToButton(
            [
              InternalViewSwitching.toTransactions(
                transactionId: -1,
                filters: FieldFilters(
                  [
                    FieldFilter(
                      fieldName: Constants.viewTransactionFieldNameCategory,
                      strings: [category.uniqueId.toString()],
                    ),
                  ],
                ),
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
    return 'Categories';
  }

  @override
  String getClassNameSingular() {
    return 'Category';
  }

  @override
  String getDescription() {
    return 'Classification of your money transactions.';
  }

  @override
  Fields<Category> getFieldsForTable() {
    return Category.fieldsForColumnView;
  }

  @override
  Widget getInfoPanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForChart(
      selectedIds: selectedIds,
      showAsNativeCurrency: showAsNativeCurrency,
    );
  }

  @override
  Widget getInfoPanelViewTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForTransactions(selectedIds);
  }

  @override
  List<Category> getList({
    bool includeDeleted = false,
    bool applyFilter = true,
  }) {
    final List<CategoryType> filterType = _getSelectedCategoryType();
    final list = Data()
        .categories
        .iterableList(includeDeleted: includeDeleted)
        .where(
          (final Category instance) =>
              (filterType.isEmpty || filterType.contains(instance.fieldType.value)) &&
              (applyFilter == false || isMatchingFilters(instance)),
        )
        .toList();
    return list;
  }

  @override
  void initState() {
    super.initState();

    _pivots.add(
      ThreePartLabel(
        key: const Key('key_toggle_show_none'),
        text1: 'None',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(
          _getTotalBalanceOfAccounts(<CategoryType>[CategoryType.none]),
        ),
      ),
    );
    _pivots.add(
      ThreePartLabel(
        key: const Key('key_toggle_show_expenses'),
        text1: 'Expense',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(
          _getTotalBalanceOfAccounts(<CategoryType>[
            CategoryType.expense,
            CategoryType.recurringExpense,
          ]),
        ),
      ),
    );
    _pivots.add(
      ThreePartLabel(
        key: const Key('key_toggle_show_income'),
        text1: 'Income',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(
          _getTotalBalanceOfAccounts(<CategoryType>[CategoryType.income]),
        ),
      ),
    );
    _pivots.add(
      ThreePartLabel(
        key: const Key('key_toggle_show_saving'),
        text1: 'Saving',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(
          _getTotalBalanceOfAccounts(<CategoryType>[CategoryType.saving]),
        ),
      ),
    );
    _pivots.add(
      ThreePartLabel(
        key: const Key('key_toggle_show_investments'),
        text1: 'Investment',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(
          _getTotalBalanceOfAccounts(<CategoryType>[CategoryType.investment]),
        ),
      ),
    );
    _pivots.add(
      ThreePartLabel(
        key: const Key('key_toggle_show_all'),
        text1: 'All',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(
          _getTotalBalanceOfAccounts(<CategoryType>[]),
        ),
      ),
    );
  }

  Widget _buildToggles() {
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
            clearSelection();
          });
        },
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        constraints: const BoxConstraints(
          minHeight: 40.0,
          minWidth: 100.0,
        ),
        isSelected: _selectedPivot,
        children: _pivots,
      ),
    );
  }

  List<CategoryType> _getSelectedCategoryType() {
    if (_selectedPivot[0]) {
      return [CategoryType.none];
    }
    if (_selectedPivot[1]) {
      return [CategoryType.expense, CategoryType.recurringExpense];
    }
    if (_selectedPivot[2]) {
      return [CategoryType.income];
    }
    if (_selectedPivot[3]) {
      return [CategoryType.saving];
    }
    if (_selectedPivot[4]) {
      return [CategoryType.investment];
    }

    return []; // all
  }

  double _getTotalBalanceOfAccounts(final List<CategoryType> types) {
    double total = 0.0;
    getList().forEach((final Category category) {
      if (types.isEmpty || (category).fieldType.value == types.first) {
        total += category.fieldSum.value.toDouble();
      }
    });
    return total;
  }
}
