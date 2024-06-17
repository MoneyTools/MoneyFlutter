import 'package:flutter/material.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/fields/field_filter.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/accounts/account_types_enum.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/loan_payments/loan_payments.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/import/import_wizard.dart';
import 'package:money/storage/preferences_helper.dart';
import 'package:money/views/adaptive_view/adaptive_list/adaptive_columns_or_rows_list.dart';
import 'package:money/views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/views/view_money_objects.dart';
import 'package:money/widgets/center_message.dart';
import 'package:money/widgets/chart.dart';
import 'package:money/widgets/columns/footer_widgets.dart';
import 'package:money/widgets/info_panel/info_panel_views_enum.dart';
import 'package:money/widgets/dialog/dialog_button.dart';
import 'package:money/widgets/three_part_label.dart';

part 'view_accounts_details_panels.dart';

part 'view_accounts_helpers.dart';

/// Main view for all Accounts
class ViewAccounts extends ViewForMoneyObjects {
  const ViewAccounts({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewAccountsState();
}

class ViewAccountsState extends ViewForMoneyObjectsState {
  ViewAccountsState() {
    viewId = ViewId.viewAccounts;
  }

  // Filter related
  final List<bool> _selectedPivot = <bool>[false, false, false, false, true];
  final List<Widget> _pivots = <Widget>[];

  // Footer related
  final DateRange _footerColumnDate = DateRange();
  int _footerCountTransactions = 0;
  double _footerSumBalance = 0.00;

  @override
  void initState() {
    super.initState();

    onAddItem = () {};

    onAddTransaction = () {
      showImportTransactionsWizard(context);
    };

    _pivots.add(
      ThreePartLabel(
        text1: 'Banks',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(0))),
      ),
    );
    _pivots.add(
      ThreePartLabel(
        text1: 'Investments',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(1))),
      ),
    );
    _pivots.add(
      ThreePartLabel(
        text1: 'Credit',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(2))),
      ),
    );
    _pivots.add(
      ThreePartLabel(
        text1: 'Assets',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(3))),
      ),
    );
    _pivots.add(
      ThreePartLabel(
        text1: 'All',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(-1))),
      ),
    );
  }

  @override
  String getClassNameSingular() {
    return 'Account';
  }

  @override
  String getClassNamePlural() {
    return 'Accounts';
  }

  @override
  String getDescription() {
    return 'Your main assets.';
  }

  @override
  String getViewId() {
    return Data().accounts.getTypeName();
  }

  @override
  Fields<Account> getFieldsForTable() {
    return Account.fields;
  }

  // default currency for this view
  @override
  List<String> getCurrencyChoices(final InfoPanelSubViewEnum subViewId, final List<int> selectedItems) {
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
  Widget buildHeader([final Widget? child]) {
    return super.buildHeader(renderToggles());
  }

  @override
  List<Widget> getActionsForSelectedItems(final bool forInfoPanelTransactions) {
    final list = super.getActionsForSelectedItems(forInfoPanelTransactions);

    if (!forInfoPanelTransactions) {
      // Place this in front off all the other actions button
      list.insert(
        0,
        buildAddItemButton(() {
          // add a new Account
          final newItem = Data().accounts.addNewAccount('New Bank Account');
          updateListAndSelect(newItem.uniqueId);
        }, 'Add new account'),
      );

      // this can go last
      if (getFirstSelectedItem() != null) {
        list.add(
          buildJumpToButton(
            [
              InternalViewSwitching(
                ViewId.viewAccounts.getIconData(),
                'Switch to Transactions',
                () {
                  final Account? account = getFirstSelectedItem() as Account?;
                  if (account != null) {
                    // Prepare the Transaction view to show only the selected account
                    FieldFilters filterByAccount = FieldFilters();
                    filterByAccount.add(FieldFilter(
                        fieldName: Constants.viewTransactionFieldnameAccount,
                        filterTextInLowerCase: account.name.value.toLowerCase()));

                    PreferencesHelper().setStringList(
                      ViewId.viewTransactions.getViewPreferenceId(settingKeyFilterColumnsText),
                      filterByAccount.toStringList(),
                    );

                    // Switch view
                    Settings().selectedView = ViewId.viewTransactions;
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

  @override
  List<Account> getList({bool includeDeleted = false, bool applyFilter = true}) {
    List<Account> list = Data().accounts.activeAccount(
          getSelectedAccountType(),
          isActive: Settings().includeClosedAccounts ? null : true,
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
  Widget getInfoPanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForChart(selectedIds: selectedIds, showAsNativeCurrency: showAsNativeCurrency);
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
}
