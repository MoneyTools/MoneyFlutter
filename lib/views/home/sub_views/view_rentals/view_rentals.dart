import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/widgets/gaps.dart';
import 'package:money/core/widgets/side_panel/side_panel.dart';
import 'package:money/data/models/money_objects/rent_buildings/rent_building.dart';
import 'package:money/data/models/money_objects/rental_unit/rental_unit.dart';
import 'package:money/data/storage/data/data.dart';
import 'package:money/views/home/sub_views/adaptive_view/view_money_objects.dart';
import 'package:money/views/home/sub_views/money_object_card.dart';
import 'package:money/views/home/sub_views/view_rentals/view_rentals_side_panel.dart';

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
    return RentBuilding.fieldsForColumnView;
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
  SidePanelSupport getSidePanelSupport() {
    return SidePanelSupport(
      onDetails: getSidePanelViewDetails,
      onChart: ViewRentalsSidePanel.getSubViewContentForChart,
      onPnL: ViewRentalsSidePanel.getSubViewContentForPnL,
      onTransactions: ViewRentalsSidePanel.getSubViewContentForTransactions,
    );
  }

  @override
  List<MoneyObject> getSidePanelTransactions() {
    final RentBuilding? item = getFirstSelectedItem() as RentBuilding?;
    if (item == null) {
      return [];
    }
    return ViewRentalsSidePanel.getTransactionLastSelectedItem(item);
  }

  @override
  Widget getSidePanelViewDetails({
    required final List<int> selectedIds,
    required final bool isReadOnly,
  }) {
    final selectedItem = getFirstSelectedItem() as RentBuilding?;
    if (selectedItem == null) {
      return const CenterMessage(message: 'No item selected.');
    }

    return SingleChildScrollView(
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 30,
          spacing: 30,
          children: [
            MoneyObjectCard(
              title: getClassNameSingular(),
              moneyObject: selectedItem,
            ),
            buildRenters(context, selectedItem),
          ],
        ),
      ),
    );
  }

  Widget buildRenters(final BuildContext context, final RentBuilding building) {
    final rentersInThisBuilding = Data()
        .rentUnits
        .iterableList()
        .where(
          (item) => item.fieldBuilding.value == building.uniqueId,
        )
        .toList();

    return buildAdaptiveBox(
      context: context,
      title: 'Renters',
      content: ListView.separated(
        itemCount: rentersInThisBuilding.length,
        itemBuilder: (context, index) {
          final renter = rentersInThisBuilding[index];
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(renter.fieldName.value),
              gapLarge(),
              Expanded(
                child: Text(renter.fieldRenter.value),
              ),
              gapLarge(),
              Text(renter.fieldNote.value),
            ],
          );
        },
        separatorBuilder: (context, index) => Divider(
          color: getColorTheme(context).onPrimaryContainer.withAlpha(100),
        ),
      ),
      count: rentersInThisBuilding.length,
    );
  }

  String getUnitsAsString(final List<RentUnit> listOfUnits) {
    final List<String> listAsText = <String>[];
    for (RentUnit unit in listOfUnits) {
      listAsText.add('${unit.fieldName}:${unit.fieldRenter}');
    }

    return listAsText.join('\n');
  }
}
