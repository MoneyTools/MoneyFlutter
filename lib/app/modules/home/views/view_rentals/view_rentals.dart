import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/splits/money_split.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/app/data/models/money_objects/rent_buildings/rent_building.dart';
import 'package:money/app/data/models/money_objects/rental_unit/rental_unit.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/views/view_rentals/rental_pnl.dart';
import 'package:money/views/view_rentals/rental_pnl_card.dart';
import 'package:money/app/core/widgets/chart.dart';
import 'package:money/views/view_money_objects.dart';
import 'package:money/views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/app/core/widgets/columns/footer_widgets.dart';

part 'view_rentals_details_panels.dart';

class ViewRentals extends ViewForMoneyObjects {
  const ViewRentals({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewRentalsState();
}

class ViewRentalsState extends ViewForMoneyObjectsState {
  ViewRentalsState() {
    viewId = ViewId.viewRentals;
  }

  RentBuilding? lastSelectedRental;

  // Footer related

  double _footerLandValue = 0.00;
  double _footerEstimatedValue = 0.00;
  int _footerTransactionsOfIncome = 0;
  int _footerTransactionsOfExpense = 0;
  double _footerRevenue = 0.00;
  double _footerExpenses = 0.00;
  double _footerProfit = 0.00;

  @override
  String getClassNamePlural() {
    return 'Rentals';
  }

  @override
  String getClassNameSingular() {
    return 'Rental';
  }

  @override
  String getDescription() {
    return 'Properties to rent.';
  }

  @override
  String getViewId() {
    return Data().rentBuildings.getTypeName();
  }

  String getUnitsAsString(final List<RentUnit> listOfUnits) {
    final List<String> listAsText = <String>[];
    for (RentUnit unit in listOfUnits) {
      listAsText.add('${unit.name}:${unit.renter}');
    }

    return listAsText.join('\n');
  }

  @override
  Widget? getColumnFooterWidget(final Field field) {
    switch (field.name) {
      case 'LandValue':
        return getFooterForAmount(_footerLandValue);
      case 'EstimatedValue':
        return getFooterForAmount(_footerEstimatedValue);
      case 'I#':
        return getFooterForInt(_footerTransactionsOfIncome);
      case 'Revenue':
        return getFooterForAmount(_footerRevenue);
      case 'E#':
        return getFooterForInt(_footerTransactionsOfExpense);
      case 'Expenses':
        return getFooterForAmount(_footerExpenses);
      case 'Profit':
        return getFooterForAmount(_footerProfit);
      default:
        return null;
    }
  }

  @override
  List<RentBuilding> getList({bool includeDeleted = false, bool applyFilter = true}) {
    final list = Data().rentBuildings.iterableList(includeDeleted: includeDeleted).toList();

    _footerExpenses = 0.00;
    _footerRevenue = 0.00;
    _footerProfit = 0.00;

    for (final item in list) {
      _footerLandValue += item.landValue.getValueForDisplay(item).toDouble();
      _footerEstimatedValue += item.estimatedValue.getValueForDisplay(item).toDouble();
      _footerTransactionsOfIncome += item.transactionsForIncomes.value.toInt();
      _footerTransactionsOfExpense += item.transactionsForExpenses.value.toInt();
      _footerExpenses += item.expense.getValueForDisplay(item).toDouble();
      _footerRevenue += item.revenue.getValueForDisplay(item).toDouble();
      _footerProfit += item.profit.getValueForDisplay(item).toDouble();
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
    return _getSubViewContentForTransactions(selectedIds);
  }

  @override
  List<MoneyObject> getInfoTransactions() {
    return getTransactionLastSelectedItem();
  }

  @override
  Fields<RentBuilding> getFieldsForTable() {
    return RentBuilding.fields!;
  }
}
