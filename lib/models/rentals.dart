import 'package:money/models/categories.dart';
import 'package:money/models/transactions.dart';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/money_entity.dart';

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

class Rentals {
  static MoneyObjects<Rental> moneyObjects = MoneyObjects<Rental>();

  static Rental? get(final int id) {
    return moneyObjects.get(id);
  }

  static String getNameFromId(final int id) {
    final Rental? found = get(id);
    if (found == null) {
      return id.toString();
    }
    return found.name;
  }

  void clear() {
    moneyObjects.clear();
  }

  load(final List<Map<String, Object?>> rows) {
    clear();

    for (final Map<String, Object?> row in rows) {
      try {
        final Rental instance = Rental.createInstanceFromRow(row);
        moneyObjects.addEntry(instance);
      } catch (error) {
        debugLog(error.toString());
      }
    }
  }

  void loadDemoData() {
    clear();

    final Rental instance = Rental(0, 'AirBnB');
    instance.address = 'One Washington DC';
    moneyObjects.addEntry(instance);
  }

  static onAllDataLoaded() {
    final List<RentUnit> allUnits = RentUnits.moneyObjects.getAsList();

    for (final Rental rental in moneyObjects.getAsList()) {
      cumulateTransactions(rental);

      // expense is a negative number so we just do a Revenue + Expense
      rental.profit = rental.revenue + rental.expense;

      for (final RentUnit unit in allUnits) {
        if (unit.building == rental.id.toString()) {
          rental.units.add(unit);
        }
      }
    }
  }

  static cumulateTransactions(final Rental rental) {
    for (Transaction t in Transactions.list) {
      if (rental.categoryForIncomeTreeIds.contains(t.categoryId)) {
        rental.dateRange.inflate(t.dateTime);
        rental.count++;
        rental.revenue += t.amount;
      } else {
        // if (listOfCategoryIdsExpenses.contains(t.categoryId)) {
        //   rental.dateRange.inflate(t.dateTime);
        //   rental.count++;
        //   rental.expense += t.amount;
        // }
      }
    }
  }
}

class RentUnit extends MoneyEntity {
  int count = 0;
  double balance = 0.00;
  String building = '';
  String renter = '';
  String note = '';

  RentUnit(super.id, super.name);
}

class RentUnits {
  static MoneyObjects<RentUnit> moneyObjects = MoneyObjects<RentUnit>();

  static RentUnit? get(final int id) {
    return moneyObjects.get(id);
  }

  static String getNameFromId(final int id) {
    final RentUnit? found = get(id);
    if (found == null) {
      return id.toString();
    }
    return found.name;
  }

  load(final List<Map<String, Object?>> rows) async {
    for (final Map<String, Object?> row in rows) {
      final int id = int.parse(row['Id'].toString());
      final String name = row['Name'].toString();

      final RentUnit instance = RentUnit(id, name);
      instance.building = row['Building'].toString();
      instance.renter = row['Renter'].toString();
      instance.note = row['Note'].toString();

      moneyObjects.addEntry(instance);
    }
  }

  loadDemoData() {}

  static onAllDataLoaded() {
    for (RentUnit item in moneyObjects.getAsList()) {
      final Rental a = item as Rental;
      a.count = 0;
      a.revenue = 0;
    }

    // for (var t in Transactions.list) {
    //   // var item = get(t.accountId);
    //   // if (item != null) {
    //   //   item.count++;
    //   //   item.balance += t.amount;
    //   // }
    // }
  }
}
