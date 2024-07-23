import 'package:flutter/widgets.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/data/models/fields/field_filter.dart';
import 'package:money/app/data/storage/data/data.dart';

class InternalViewSwitching {
  InternalViewSwitching({required this.icon, required this.title, required this.onPressed});

  factory InternalViewSwitching.toAccounts({required final int accountId}) {
    return InternalViewSwitching(
      icon: ViewId.viewAccounts.getIconData(),
      title: 'Switch to Account',
      onPressed: () {
        // Prepare the Account view to show only the selected account
        final accountInstance = Data().accounts.get(accountId);
        if (accountInstance != null) {
          PreferenceController.to.jumpToView(
            viewId: ViewId.viewAccounts,
            selectedId: accountId,
            columnFilter: [],
            textFilter: '',
          );

          if (accountInstance.isClosed()) {
            // we must show closed account in order to reveal this requested account selection
            if (PreferenceController.to.includeClosedAccounts == false) {
              PreferenceController.to.includeClosedAccounts = true;
            }
          }
        }
      },
    );
  }

  factory InternalViewSwitching.toInvestments({
    final String symbol = '',
    final String accountName = '',
  }) {
    late FieldFilter fieldFilterToUse;
    if (symbol.isNotEmpty) {
      fieldFilterToUse = FieldFilter(
        fieldName: Constants.viewStockFieldnameSymbol,
        filterTextInLowerCase: symbol.toLowerCase(),
      );
    } else {
      if (accountName.isNotEmpty) {
        fieldFilterToUse = FieldFilter(
          fieldName: Constants.viewStockFieldnameAccount,
          filterTextInLowerCase: accountName.toLowerCase(),
        );
      }
    }

    // Jump to Stock view
    return InternalViewSwitching(
      icon: ViewId.viewInvestments.getIconData(),
      title: 'Switch to Investments',
      onPressed: () {
        PreferenceController.to.jumpToView(
          viewId: ViewId.viewInvestments,
          selectedId: -1,
          columnFilter: FieldFilters([fieldFilterToUse]).toStringList(),
          textFilter: '',
        );
      },
    );
  }

  factory InternalViewSwitching.toTransactions({
    required final int transactionId,
    final FieldFilters? filters,
    final String filterText = '',
  }) {
    return InternalViewSwitching(
      icon: ViewId.viewTransactions.getIconData(),
      title: 'Switch to Transactions',
      onPressed: () {
        // Prepare the Transaction view Filter to show only the selected account
        PreferenceController.to.jumpToView(
          viewId: ViewId.viewTransactions,
          selectedId: transactionId,
          columnFilter: filters?.toStringList() ?? [],
          textFilter: filterText,
        );
      },
    );
  }

  final IconData? icon;
  final Function onPressed;
  final String title;
}
