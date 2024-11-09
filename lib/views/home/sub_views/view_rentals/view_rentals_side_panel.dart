import 'package:money/core/controller/list_controller.dart';
import 'package:money/core/controller/selection_controller.dart';
import 'package:money/core/widgets/widgets.dart';
import 'package:money/data/models/money_objects/rent_buildings/rent_building.dart';
import 'package:money/data/models/money_objects/splits/money_split.dart';
import 'package:money/data/models/money_objects/transactions/transaction.dart';
import 'package:money/data/storage/data/data.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/views/home/sub_views/view_rentals/rental_pnl.dart';
import 'package:money/views/home/sub_views/view_rentals/rental_pnl_card.dart';

class ViewRentalsSidePanel {
  static bool filterByRentalCategories(
    final Transaction t,
    final RentBuilding rental,
  ) {
    final num categoryIdToMatch = t.fieldCategoryId.value;

    if (t.isSplit) {
      for (final MoneySplit split in t.splits) {
        if (isMatchingCategories(split.fieldCategoryId.value, rental)) {
          return true;
        }
      }
      return false;
    }

    return isMatchingCategories(categoryIdToMatch, rental);
  }

  static List<RentBuilding> getList() {
    return Data().rentBuildings.iterableList(includeDeleted: true).toList();
  }

  void getPnLOverYears(RentBuilding rental) {
    for (final transaction in Data().transactions.iterableList()) {
      if (rental.categoryForIncomeTreeIds.contains(transaction.fieldCategoryId.value)) {}
    }
  }

  /// Details panels Chart panel for Payees
  static Widget getSubViewContentForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final List<PairXY> list = <PairXY>[];
    for (final RentBuilding entry in getList()) {
      list.add(PairXY(entry.fieldName.value, entry.lifeTimePnL.profit));
    }
    return Chart(
      list: list,
    );
  }

  static Widget getSubViewContentForPnL({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    if (selectedIds.isEmpty) {
      return Text('Select a Rental property to see its P&L');
    }

    //
    // Single Rental property selected
    //

    RentBuilding rental = Data().rentBuildings.get(selectedIds.first) as RentBuilding;

    // show PnL for the selected rental property, per year
    List<Widget> pnlCards = [];

    if (!rental.dateRangeOfOperation.hasNullDates) {
      for (int year = rental.dateRangeOfOperation.min!.year; year <= rental.dateRangeOfOperation.max!.year; year++) {
        RentalPnL? pnl = rental.pnlOverYears[year];
        pnl ??= RentalPnL(date: DateTime(year, 1, 1));
        pnlCards.add(RentalPnLCard(pnl: pnl));
      }
    }

    pnlCards.add(
      RentalPnLCard(
        pnl: rental.lifeTimePnL,
        customTitle: 'Life Time P&L',
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: pnlCards,
      ),
    );
  }

  // Details Panel for Transactions Payees
  static Widget getSubViewContentForTransactions({
    required final List<int> selectedIds,
    required bool showAsNativeCurrency,
  }) {
    RentBuilding rental = Data().rentBuildings.get(selectedIds.first) as RentBuilding;
    final SelectionController selectionController = Get.put(SelectionController());
    return ListViewTransactions(
      listController: Get.find<ListControllerSidePanel>(),
      columnsToInclude: <Field>[
        Transaction.fields.getFieldByName(columnIdDate),
        Transaction.fields.getFieldByName(columnIdAccount),
        Transaction.fields.getFieldByName(columnIdPayee),
        Transaction.fields.getFieldByName(columnIdCategory),
        Transaction.fields.getFieldByName(columnIdMemo),
        Transaction.fields.getFieldByName(columnIdAmount),
      ],
      getList: () => getTransactionLastSelectedItem(rental),
      selectionController: selectionController,
    );
  }

  static List<Transaction> getTransactionLastSelectedItem(RentBuilding rentBuildings) {
    return getTransactions(
      filter: (final Transaction transaction) => filterByRentalCategories(
        transaction,
        rentBuildings,
      ),
    );
  }

  static bool isMatchingCategories(
    final num categoryIdToMatch,
    final RentBuilding rental,
  ) {
    Data().categories.getTreeIds(rental.categoryForIncome.value);

    return rental.categoryForIncomeTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForManagementTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForRepairsTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForMaintenanceTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForTaxesTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForInterestTreeIds.contains(categoryIdToMatch);
  }
}
