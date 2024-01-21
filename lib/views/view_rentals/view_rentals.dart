import 'package:flutter/material.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/money_object.dart';

import 'package:money/models/money_objects/rent_buildings/rent_building.dart';
import 'package:money/models/money_objects/rental_unit/rental_unit.dart';
import 'package:money/models/money_objects/splits/split.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

import 'package:money/widgets/chart.dart';
import 'package:money/views/view.dart';
import 'package:money/widgets/table_view/table_transactions.dart';

part 'view_rentals_details_panels.dart';

class ViewRentals extends ViewWidget<RentBuilding> {
  const ViewRentals({super.key});

  @override
  State<ViewWidget<RentBuilding>> createState() => ViewRentalsState();
}

class ViewRentalsState extends ViewWidgetState<RentBuilding> {
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
  List<RentBuilding> getList() {
    return Data().rentBuildings.getList();
  }

  @override
  int getDefaultSortColumn() {
    return 0; // Sort by name
  }

  @override
  Widget getPanelForChart(final List<int> indices) {
    return _getSubViewContentForChart(indices);
  }

  @override
  Widget getPanelForTransactions(final List<int> indices) {
    return _getSubViewContentForTransactions(indices);
  }
}
