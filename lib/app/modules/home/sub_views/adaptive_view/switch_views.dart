import 'package:flutter/widgets.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/fields/field_filter.dart';

class InternalViewSwitching {
  InternalViewSwitching({required this.icon, required this.title, required this.onPressed});

  factory InternalViewSwitching.toAccounts({required final int accountId}) {
    return InternalViewSwitching(
      icon: ViewId.viewAccounts.getIconData(),
      title: 'Switch to Account',
      onPressed: () {
        // Prepare the Account view to show only the selected account
        PreferenceController.to.jumpToView(
          viewId: ViewId.viewAccounts,
          selectedId: accountId,
          columnFilter: [],
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
