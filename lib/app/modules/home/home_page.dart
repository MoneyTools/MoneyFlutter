import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/controller/data_controller.dart';
import 'package:money/app/modules/home/sub_views/app_bar.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/modules/home/sub_views/sub_view_selection.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/controller/general_controller.dart';
import 'package:money/app/modules/home/sub_views/app_scaffold.dart';
import 'package:money/app/modules/home/sub_views/view_accounts/view_accounts.dart';
import 'package:money/app/modules/home/sub_views/view_aliases/view_aliases.dart';
import 'package:money/app/modules/home/sub_views/view_cashflow/view_cashflow.dart';
import 'package:money/app/modules/home/sub_views/view_categories/view_categories.dart';
import 'package:money/app/modules/home/sub_views/view_investments/view_investments.dart';
import 'package:money/app/modules/home/sub_views/view_payees/view_payees.dart';
import 'package:money/app/modules/policies/view_policy.dart';
import 'package:money/app/modules/home/sub_views/view_rentals/view_rentals.dart';
import 'package:money/app/modules/home/sub_views/view_stocks/view_stocks.dart';
import 'package:money/app/modules/home/sub_views/view_transactions/view_transactions.dart';
import 'package:money/app/modules/home/sub_views/view_transfers/view_transfers.dart';
import 'package:money/app/core/widgets/working.dart';

import 'home_controller.dart';

RxInt subViewInt = 0.obs;

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final DataController dataController = Get.find();
    return Obx(() {
      return myScaffold(
        context,
        const MyAppBar(),
        dataController.isLoading.value ? const WorkingIndicator() : _buildAdativeContent(context),
      );
    });
  }

  Widget _buildAdativeContent(BuildContext context) {
    if (isSmallDevice(context)) {
      // small screens
      return _buildContentForSmallSurface(context);
    } else {
      // Large screens
      return _buildContentForLargeSurface(context);
    }
  }

  Widget _buildContentForLargeSurface(final BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SubViewSelectionVertical(
            key: Key(PreferenceController.to.currentView.value.toString()),
            onSelectItem: _handleSubViewSelectionChanged,
            selectedView: PreferenceController.to.currentView.value,
            useIndicator: true,
          ),
          Expanded(
            child: Container(
              color: getColorTheme(context).secondaryContainer,
              child: _getSubView(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContentForSmallSurface(final BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: _getSubView(),
        ),
        SubViewSelectionHorizontal(
            key: Key(PreferenceController.to.currentView.value.toString()),
            onSelected: _handleSubViewSelectionChanged,
            selectedView: PreferenceController.to.currentView.value),
      ],
    );
  }

  Widget _getSubView() {
    switch (PreferenceController.to.currentView.value) {
      case ViewId.viewAccounts:
        return ViewAccounts(includeClosedAccount: GeneralController().ctlPref.includeClosedAccounts);

      case ViewId.viewCategories:
        return const ViewCategories();

      case ViewId.viewPayees:
        return const ViewPayees();

      case ViewId.viewAliases:
        return const ViewAliases();

      case ViewId.viewTransactions:
        return const ViewTransactions();

      case ViewId.viewTransfers:
        return const ViewTransfers();

      case ViewId.viewInvestments:
        return const ViewInvestments();

      case ViewId.viewStocks:
        return const ViewStocks();

      case ViewId.viewRentals:
        return const ViewRentals();

      case ViewId.viewPolicy:
        return const PolicyScreen();

      case ViewId.viewCashFlow:
      default:
        return const ViewCashFlow();
    }
  }

  void _handleSubViewSelectionChanged(final ViewId selectedView) {
    PreferenceController.to.setView(selectedView);
  }
}
