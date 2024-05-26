import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/accounts/account_types_enum.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/import/import_transactions_from_text.dart';
import 'package:money/views/action_buttons.dart';
import 'package:money/views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/views/view_money_objects.dart';
import 'package:money/widgets/center_message.dart';
import 'package:money/widgets/chart.dart';
import 'package:money/widgets/details_panel/info_panel_views_enum.dart';
import 'package:money/widgets/three_part_label.dart';

part 'view_accounts_details_panels.dart';

part 'view_accounts_helpers.dart';

final List<bool> _selectedPivot = <bool>[false, false, false, false, true];

/// Main view for all Accounts
class ViewAccounts extends ViewForMoneyObjects {
  const ViewAccounts({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewAccountsState();
}

class ViewAccountsState extends ViewForMoneyObjectsState {
  final List<Widget> pivots = <Widget>[];
  Account? lastSelectedAccount;

  ViewAccountsState() {
    onCopyInfoPanelTransactions = _onCopyInfoPanelTransactions;
  }

  @override
  void initState() {
    super.initState();

    onAddItem = () {};

    onAddTransaction = () {
      showImportTransactions(context);
    };

    pivots.add(
      ThreePartLabel(
        text1: 'Banks',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(0))),
      ),
    );
    pivots.add(
      ThreePartLabel(
        text1: 'Investments',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(1))),
      ),
    );
    pivots.add(
      ThreePartLabel(
        text1: 'Credit',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(2))),
      ),
    );
    pivots.add(
      ThreePartLabel(
        text1: 'Assets',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(3))),
      ),
    );
    pivots.add(
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
      list.insert(
        0,
        buildAddItemButton(() {
          // add a new Account
          final newItem = Data().accounts.addNewAccount('New Bank Account');
          updateListAndSelect(newItem.uniqueId);
        }, 'Add new account'),
      );
    }

    return list;
  }

  @override
  List<Account> getList({bool includeDeleted = false, bool applyFilter = true}) {
    final list = Data().accounts.activeAccount(
          getSelectedAccountType(),
          isActive: Settings().includeClosedAccounts ? null : true,
        );

    if (applyFilter) {
      return list.where((final Account instance) => isMatchingFilters(instance)).toList();
    } else {
      return list.toList();
    }
  }

  @override
  void setSelectedItem(final int uniqueId) {
    final Account? account = getMoneyObjectFromFirstSelectedId<Account>(<int>[uniqueId], list);
    if (account != null && account.id.value > -1) {
      Settings().mostRecentlySelectedAccount = account;
    }
    super.setSelectedItem(uniqueId);
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
    final Account? account = getMoneyObjectFromFirstSelectedId<Account>(selectedIds, list);
    if (account == null) {
      return const CenterMessage(message: 'No account selected.');
    } else {
      return _getSubViewContentForTransactions(
        account: account,
        showAsNativeCurrency: showAsNativeCurrency,
      );
    }
  }

  void _onCopyInfoPanelTransactions() {
    final list = getTransactionForLastSelectedAccount();
    copyToClipboardAndInformUser(context, MoneyObjects.getCsvFromList(list));
  }
}
