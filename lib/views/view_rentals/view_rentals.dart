import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/splits/money_split.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/rent_buildings/rent_building.dart';
import 'package:money/models/money_objects/rental_unit/rental_unit.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/views/view_rentals/rental_pnl.dart';
import 'package:money/views/view_rentals/rental_pnl_card.dart';
import 'package:money/widgets/chart.dart';
import 'package:money/views/view_money_objects.dart';
import 'package:money/views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';

part 'view_rentals_details_panels.dart';

class ViewRentals extends ViewForMoneyObjects {
  const ViewRentals({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewRentalsState();
}

class ViewRentalsState extends ViewForMoneyObjectsState {
  RentBuilding? lastSelectedRental;

  ViewRentalsState() {
    onCopyInfoPanelTransactions = _onCopyInfoPanelTransactions;
  }

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
  MyJson getViewChoices() {
    return Data().rentBuildings.getLastViewChoices();
  }

  String getUnitsAsString(final List<RentUnit> listOfUnits) {
    final List<String> listAsText = <String>[];
    for (RentUnit unit in listOfUnits) {
      listAsText.add('${unit.name}:${unit.renter}');
    }

    return listAsText.join('\n');
  }

  @override
  List<RentBuilding> getList({bool includeDeleted = false, bool applyFilter = true}) {
    return Data().rentBuildings.iterableList(includeDeleted: includeDeleted).toList();
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

  void _onCopyInfoPanelTransactions() {
    final list = getTransactionLastSelectedItem();
    copyToClipboardAndInformUser(context, MoneyObjects.getCsvFromList(list));
  }

  @override
  Fields<RentBuilding> getFieldsForTable() {
    return RentBuilding.fields!;
  }
}
