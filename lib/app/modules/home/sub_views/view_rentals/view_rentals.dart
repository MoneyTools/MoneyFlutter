import 'package:money/app/controller/selection_controller.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/data/models/money_objects/rent_buildings/rent_building.dart';
import 'package:money/app/data/models/money_objects/rental_unit/rental_unit.dart';
import 'package:money/app/data/models/money_objects/splits/money_split.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/view_money_objects.dart';
import 'package:money/app/modules/home/sub_views/view_rentals/rental_pnl.dart';
import 'package:money/app/modules/home/sub_views/view_rentals/rental_pnl_card.dart';

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
  Fields<RentBuilding> getFieldsForTable() {
    return RentBuilding.fields;
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
    return _getSubViewContentForTransactions(selectedIds);
  }

  @override
  List<MoneyObject> getInfoTransactions() {
    return getTransactionLastSelectedItem();
  }

  @override
  List<RentBuilding> getList({
    bool includeDeleted = false,
    bool applyFilter = true,
  }) {
    final list = Data().rentBuildings.iterableList(includeDeleted: includeDeleted).toList();

    return list;
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
}
