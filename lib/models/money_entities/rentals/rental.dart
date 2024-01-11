import 'package:money/models/money_entities/categories/categories.dart';
import 'package:money/models/money_entities/rentals/rental_unit.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/money_entities/money_entity.dart';

class Rental extends MoneyEntity {
  int count = 0;

  double revenue = 0.00;
  double expense = 0.00;
  double profit = 0.00;

  String address = '';
  DateTime purchasedDate = DateTime.now();
  double purchasedPrice = 0.00;
  double landValue = 0.00;
  double estimatedValue = 0.00;

  int categoryForIncome = -1;
  List<int> categoryForIncomeTreeIds = <int>[];

  int categoryForTaxes = -1;
  List<int> categoryForTaxesTreeIds = <int>[];

  int categoryForInterest = -1;
  List<int> categoryForInterestTreeIds = <int>[];

  int categoryForRepairs = -1;
  List<int> categoryForRepairsTreeIds = <int>[];

  int categoryForMaintenance = -1;
  List<int> categoryForMaintenanceTreeIds = <int>[];

  int categoryForManagement = -1;
  List<int> categoryForManagementTreeIds = <int>[];

  List<int> listOfCategoryIdsExpenses = <int>[];

  String ownershipName1 = '';
  String ownershipName2 = '';
  double ownershipPercentage1 = 0.0;
  double ownershipPercentage2 = 0.0;
  String note = '';
  List<RentUnit> units = <RentUnit>[];

  DateRange dateRange = DateRange();

  Rental(super.id, super.name);

  static Rental createInstanceFromRow(final Map<String, Object?> row) {
    final int id = MoneyEntity.fromRowColumnToNumber(row, 'Id');
    final String name = MoneyEntity.fromRowColumnToString(row, 'Name');

    final Rental instance = Rental(id, name);

    instance.address = MoneyEntity.fromRowColumnToString(row, 'Address');
    instance.purchasedDate = MoneyEntity.fromRowColumnToDateTime(row, 'PurchasedDate') ?? DateTime.now();
    instance.purchasedPrice = MoneyEntity.fromRowColumnToDouble(row, 'PurchasedPrice');
    instance.landValue = MoneyEntity.fromRowColumnToDouble(row, 'LandValue');
    instance.estimatedValue = MoneyEntity.fromRowColumnToDouble(row, 'EstimatedValue');

    instance.categoryForIncome = MoneyEntity.fromRowColumnToNumber(row, 'CategoryForIncome');
    instance.categoryForIncomeTreeIds = Categories.getTreeIds(instance.categoryForIncome);

    instance.categoryForTaxes = MoneyEntity.fromRowColumnToNumber(row, 'CategoryForTaxes');
    instance.categoryForTaxesTreeIds = Categories.getTreeIds(instance.categoryForTaxes);

    instance.categoryForInterest = MoneyEntity.fromRowColumnToNumber(row, 'CategoryForInterest');
    instance.categoryForInterestTreeIds = Categories.getTreeIds(instance.categoryForInterest);

    instance.categoryForRepairs = MoneyEntity.fromRowColumnToNumber(row, 'CategoryForRepairs');
    instance.categoryForRepairsTreeIds = Categories.getTreeIds(instance.categoryForRepairs);

    instance.categoryForMaintenance = MoneyEntity.fromRowColumnToNumber(row, 'CategoryForMaintenance');
    instance.categoryForMaintenanceTreeIds = Categories.getTreeIds(instance.categoryForMaintenance);

    instance.categoryForManagement = MoneyEntity.fromRowColumnToNumber(row, 'CategoryForManagement');
    instance.categoryForManagementTreeIds = Categories.getTreeIds(instance.categoryForManagement);

    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForTaxesTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForMaintenanceTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForManagementTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForRepairsTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForInterestTreeIds);

    instance.ownershipName1 = MoneyEntity.fromRowColumnToString(row, 'OwnershipName1');
    instance.ownershipName2 = MoneyEntity.fromRowColumnToString(row, 'OwnershipName2');
    instance.ownershipPercentage1 = MoneyEntity.fromRowColumnToDouble(row, 'ownershipPercentage1');
    instance.ownershipPercentage2 = MoneyEntity.fromRowColumnToDouble(row, 'ownershipPercentage1');
    instance.note = MoneyEntity.fromRowColumnToString(row, 'Note');

    return instance;
  }
}
