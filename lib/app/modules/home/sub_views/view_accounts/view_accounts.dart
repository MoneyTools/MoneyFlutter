import 'package:flutter/material.dart';
import 'package:money/app/controller/data_controller.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/controller/selection_controller.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/ranges.dart';
import 'package:money/app/core/widgets/center_message.dart';
import 'package:money/app/core/widgets/chart.dart';
import 'package:money/app/core/widgets/columns/footer_widgets.dart';
import 'package:money/app/core/widgets/dialog/dialog_button.dart';
import 'package:money/app/core/widgets/dialog/dialog_mutate_money_object.dart';
import 'package:money/app/core/widgets/info_panel/info_panel_views_enum.dart';
import 'package:money/app/core/widgets/snack_bar.dart';
import 'package:money/app/core/widgets/three_part_label.dart';
import 'package:money/app/data/models/constants.dart';

import 'package:money/app/data/models/fields/field_filter.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/accounts/account_types_enum.dart';
import 'package:money/app/data/models/money_objects/currencies/currency.dart';
import 'package:money/app/data/models/money_objects/loan_payments/loan_payments.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/data/storage/import/import_wizard.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/adaptive_columns_or_rows_list.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/app/modules/home/sub_views/view_money_objects.dart';

part 'view_accounts_details_panels.dart';
part 'view_accounts_helpers.dart';

/// Main view for all Accounts
class ViewAccounts extends ViewForMoneyObjects {
  const ViewAccounts({super.key, super.includeClosedAccount});

  @override
  State<ViewForMoneyObjects> createState() => ViewAccountsState();
}

class ViewAccountsState extends ViewForMoneyObjectsState {
  ViewAccountsState() {
    viewId = ViewId.viewAccounts;
  }

  // Footer related
  final DateRange _footerColumnDate = DateRange();

  int _footerCountTransactions = 0;
  double _footerSumBalance = 0.00;
  final List<Widget> _pivots = <Widget>[];
  // Filter related
  final List<bool> _selectedPivot = <bool>[false, false, false, false, true];

  @override
  Widget buildHeader([final Widget? child]) {
    return super.buildHeader(renderToggles());
  }

  @override
  void didUpdateWidget(ViewAccounts oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle changes in widget properties
    if (oldWidget.includeClosedAccount != widget.includeClosedAccount) {
      list = getList();
    }
  }

  @override
  List<Widget> getActionsButtons(final bool forInfoPanelTransactions) {
    final list = super.getActionsButtons(forInfoPanelTransactions);

    if (forInfoPanelTransactions) {
      list.add(
        buildJumpToButton(
          [
            InternalViewSwitching(
              ViewId.viewTransactions.getIconData(),
              'Matching Transaction',
              () {
                final selectedInfotransaction = getLastInfoPanelTransactionSelection();

                if (selectedInfotransaction != null) {
                  // Look for transaction matching -1 to +1 date from this transaction
                  final DateRange approximationDates = DateRange(
                    min: selectedInfotransaction.dateTime.value!.add(const Duration(days: -1)).startOfDay,
                    max: selectedInfotransaction.dateTime.value!.add(const Duration(days: 1)).endOfDay,
                  );
                  // we are looking for the reverse transaction
                  final double amountToFind = selectedInfotransaction.amount.value.toDouble() * -1;

                  final matchingTransaction = Data().transactions.findExistingTransaction(
                        accountId: -1,
                        dateRange: approximationDates,
                        amount: amountToFind,
                      );
                  // Switch view
                  if (matchingTransaction != null) {
                    PreferenceController.to.jumpToView(
                      viewId: ViewId.viewTransactions,
                      selectedId: matchingTransaction.uniqueId,
                      columnFilter: [],
                      textFilter: '',
                    );
                    return;
                  }
                }
                SnackBarService.displayWarning(message: 'No matching transactons');
              },
            ),
          ],
        ),
      );
    } else {
      // Place this in front off all the other actions button
      list.insert(
        0,
        buildAddItemButton(
          () {
            // add a new Account
            final newItem = Data().accounts.addNewAccount('New Bank Account');
            updateListAndSelect(newItem.uniqueId);
          },
          'Add new account',
        ),
      );

      // this can go last
      if (getFirstSelectedItem() != null) {
        list.add(
          buildJumpToButton(
            [
              InternalViewSwitching(
                ViewId.viewTransactions.getIconData(),
                'Switch to Transactions',
                () {
                  final Account? account = getFirstSelectedItem() as Account?;
                  if (account != null) {
                    // Prepare the Transaction view Filter to show only the selected account
                    FieldFilters columnFilters = FieldFilters();
                    columnFilters.add(
                      FieldFilter(
                        fieldName: Constants.viewTransactionFieldnameAccount,
                        filterTextInLowerCase: account.name.value.toLowerCase(),
                      ),
                    );

                    // Switch view
                    PreferenceController.to.jumpToView(
                      viewId: ViewId.viewTransactions,
                      selectedId: -1,
                      columnFilter: columnFilters.toStringList(),
                      textFilter: '',
                    );
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
    return 'Accounts';
  }

  @override
  String getClassNameSingular() {
    return 'Account';
  }

  @override
  Widget? getColumnFooterWidget(final Field field) {
    switch (field.name) {
      case 'Transactions':
        return getFooterForInt(_footerCountTransactions);
      case 'Balance(USD)':
        return getFooterForAmount(_footerSumBalance);
      case 'Updated':
        return getFooterForDateRange(_footerColumnDate);
      default:
        return null;
    }
  }

  // default currency for this view
  @override
  List<String> getCurrencyChoices(
    final InfoPanelSubViewEnum subViewId,
    final List<int> selectedItems,
  ) {
    switch (subViewId) {
      case InfoPanelSubViewEnum.chart: // Chart
      case InfoPanelSubViewEnum.transactions: // Transactions
        final Account? account = getFirstSelectedItemFromSelectedList(selectedItems) as Account?;
        if (account != null) {
          if (account.currency.value != Constants.defaultCurrency) {
            // only offer currency toggle if the account is not USD based
            return [account.currency.value, Constants.defaultCurrency];
          }
        }

        return [Constants.defaultCurrency];
      default:
        return [];
    }
  }

  @override
  String getDescription() {
    return 'Your main assets.';
  }

  @override
  Fields<Account> getFieldsForTable() {
    return Account.fields;
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
    final Account? account = getFirstSelectedItem() as Account?;
    if (account == null) {
      return const CenterMessage(message: 'No account selected.');
    } else {
      if (account.type.value == AccountType.loan) {
        return _getSubViewContentForTransactionsForLoans(
          account: account,
          showAsNativeCurrency: showAsNativeCurrency,
        );
      } else {
        return _getSubViewContentForTransactions(
          account: account,
          showAsNativeCurrency: showAsNativeCurrency,
        );
      }
    }
  }

  @override
  List<MoneyObject> getInfoTransactions() {
    final Account? account = getFirstSelectedItem() as Account?;
    if (account != null) {
      return getTransactionForLastSelectedAccount(account);
    }
    return [];
  }

  @override
  List<Account> getList({
    bool includeDeleted = false,
    bool applyFilter = true,
  }) {
    List<Account> list = Data().accounts.activeAccount(
          getSelectedAccountType(),
          isActive: PreferenceController.to.includeClosedAccounts ? null : true,
        );

    if (applyFilter) {
      list = list.where((final Account instance) => isMatchingFilters(instance)).toList();
    } else {
      list = list.toList();
    }

    _footerCountTransactions = 0;
    _footerSumBalance = 0.00;
    _footerColumnDate.clear();

    for (final account in list) {
      _footerCountTransactions += account.count.value.toInt();
      _footerSumBalance += (account.balanceNormalized.getValueForDisplay(account) as MoneyModel).toDouble();
      _footerColumnDate.inflate(account.updatedOn.value);
    }
    return list;
  }

  @override
  String getViewId() {
    return Data().accounts.getTypeName();
  }

  @override
  void initState() {
    super.initState();

    onAddTransaction = () {
      showImportTransactionsWizard(context);
    };

    _pivots.add(
      ThreePartLabel(
        text1: 'Banks',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(
          getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(0)),
        ),
      ),
    );
    _pivots.add(
      ThreePartLabel(
        text1: 'Investments',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(
          getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(1)),
        ),
      ),
    );
    _pivots.add(
      ThreePartLabel(
        text1: 'Credit',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(
          getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(2)),
        ),
      ),
    );
    _pivots.add(
      ThreePartLabel(
        text1: 'Assets',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(
          getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(3)),
        ),
      ),
    );
    _pivots.add(
      ThreePartLabel(
        text1: 'All',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(
          getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(-1)),
        ),
      ),
    );
  }
}
