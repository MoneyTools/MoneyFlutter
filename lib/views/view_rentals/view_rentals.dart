import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/money_object.dart';

import 'package:money/models/money_objects/rent_buildings/rent_building.dart';
import 'package:money/models/money_objects/rental_unit/rental_unit.dart';
import 'package:money/models/money_objects/splits/split.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/views/view_rentals/rental_pnl.dart';
import 'package:money/views/view_rentals/rental_pnl_card.dart';
import 'package:money/widgets/center_message.dart';

import 'package:money/widgets/chart.dart';
import 'package:money/views/view.dart';
import 'package:money/widgets/list_view/transactions/list_view_transactions.dart';

part 'view_rentals_details_panels.dart';

class ViewRentals extends ViewWidget {
  const ViewRentals({super.key});

  @override
  State<ViewWidget> createState() => ViewRentalsState();
}

class ViewRentalsState extends ViewWidgetState {
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

  String getUnitsAsString(final List<RentUnit> listOfUnits) {
    final List<String> listAsText = <String>[];
    for (RentUnit unit in listOfUnits) {
      listAsText.add('${unit.name}:${unit.renter}');
    }

    return listAsText.join('\n');
  }

  @override
  List<RentBuilding> getList({bool includeDeleted = false, bool applyFilter = true}) {
    return Data().rentBuildings.iterableList(includeDeleted).toList();
  }

  @override
  Widget getPanelForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForChart(selectedIds: selectedIds, showAsNativeCurrency: showAsNativeCurrency);
  }

  @override
  Widget getPanelForTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForTransactions(selectedIds);
  }

  @override
  Fields<RentBuilding> getFieldsForTable() {
    return RentBuilding.fields!;
  }

  @override
  void onDeleteConfirmedByUser(final MoneyObject instance) {
    setState(() {
      Data().rentBuildings.deleteItem(instance);
    });
  }
}
