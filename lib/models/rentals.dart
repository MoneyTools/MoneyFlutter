import 'package:money/models/categories.dart';
import 'package:money/models/transactions.dart';

import '../helpers.dart';
import 'date_range.dart';
import 'money_entity.dart';

class Rental extends MoneyEntity {
  int count = 0;

  double revenue = 0.00;
  double expense = 0.00;
  double profit = 0.00;

  String address = "";
  DateTime purchasedDate = DateTime.now();
  double purchasedPrice = 0.00;
  double landValue = 0.00;
  double estimatedValue = 0.00;

  num categoryForIncome = -1;
  List<num> categoryForIncomeTreeIds = [];

  num categoryForTaxes = -1;
  List<num> categoryForTaxesTreeIds = [];

  num categoryForInterest = -1;
  List<num> categoryForInterestTreeIds = [];

  num categoryForRepairs = -1;
  List<num> categoryForRepairsTreeIds = [];

  num categoryForMaintenance = -1;
  List<num> categoryForMaintenanceTreeIds = [];

  num categoryForManagement = -1;
  List<num> categoryForManagementTreeIds = [];

  List<num> listOfCategoryIdsExpenses = [];

  String ownershipName1 = "";
  String ownershipName2 = "";
  double ownershipPercentage1 = 0.0;
  double ownershipPercentage2 = 0.0;
  String note = "";
  List<RentUnit> units = [];

  DateRange dateRange = DateRange();

  Rental(id, name) : super(id, name) {
    //
  }

  static Rental createInstanceFromRow(row) {
    var id = MoneyEntity.fromRowColumnToNumber(row, "Id");
    var name = MoneyEntity.fromRowColumnToString(row, "Name");

    var instance = Rental(id, name);

    instance.address = MoneyEntity.fromRowColumnToString(row, "Address");
    instance.purchasedDate = DateTime.parse(row["PurchasedDate"].toString());
    instance.purchasedPrice = MoneyEntity.fromRowColumnToDouble(row, "PurchasedPrice");
    instance.landValue = MoneyEntity.fromRowColumnToDouble(row, "LandValue");
    instance.estimatedValue = MoneyEntity.fromRowColumnToDouble(row, "EstimatedValue");

    instance.categoryForIncome = MoneyEntity.fromRowColumnToNumber(row, "CategoryForIncome");
    instance.categoryForIncomeTreeIds = Categories.getTreeIds(instance.categoryForIncome);

    instance.categoryForTaxes = MoneyEntity.fromRowColumnToNumber(row, "CategoryForTaxes");
    instance.categoryForTaxesTreeIds = Categories.getTreeIds(instance.categoryForTaxes);

    instance.categoryForInterest = MoneyEntity.fromRowColumnToNumber(row, "CategoryForInterest");
    instance.categoryForInterestTreeIds = Categories.getTreeIds(instance.categoryForInterest);

    instance.categoryForRepairs = MoneyEntity.fromRowColumnToNumber(row, "CategoryForRepairs");
    instance.categoryForRepairsTreeIds = Categories.getTreeIds(instance.categoryForRepairs);

    instance.categoryForMaintenance = MoneyEntity.fromRowColumnToNumber(row, "CategoryForMaintenance");
    instance.categoryForMaintenanceTreeIds = Categories.getTreeIds(instance.categoryForMaintenance);

    instance.categoryForManagement = MoneyEntity.fromRowColumnToNumber(row, "CategoryForManagement");
    instance.categoryForManagementTreeIds = Categories.getTreeIds(instance.categoryForManagement);

    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForTaxesTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForMaintenanceTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForManagementTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForRepairsTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForInterestTreeIds);

    instance.ownershipName1 = MoneyEntity.fromRowColumnToString(row, "OwnershipName1");
    instance.ownershipName2 = MoneyEntity.fromRowColumnToString(row, "OwnershipName2");
    instance.ownershipPercentage1 = MoneyEntity.fromRowColumnToDouble(row, "ownershipPercentage1");
    instance.ownershipPercentage2 = MoneyEntity.fromRowColumnToDouble(row, "ownershipPercentage1");
    instance.note = MoneyEntity.fromRowColumnToString(row, "Note");

    return instance;
  }
}

class Rentals {
  static MoneyObjects moneyObjects = MoneyObjects();

  static Rental? get(id) {
    return moneyObjects.get(id) as Rental?;
  }

  static String getNameFromId(num id) {
    var found = get(id);
    if (found == null) {
      return id.toString();
    }
    return found.name;
  }

  void clear() {
    moneyObjects.clear();
  }

  load(rows) {
    clear();

    for (var row in rows) {
      try {
        Rental instance = Rental.createInstanceFromRow(row);
        moneyObjects.addEntry(instance);
      } catch (error) {
        debugLog(error);
      }
    }
  }

  void loadDemoData() {
    clear();

    var instance = Rental(0, "AirBnB");
    instance.address = "One Washington DC";
    moneyObjects.addEntry(instance);
  }

  static onAllDataLoaded() {
    var allUnits = RentUnits.moneyObjects.getAsList();

    for (var building in moneyObjects.getAsList()) {
      var rental = building as Rental;
      // debugLog(rental.name);
      cumulateTransactions(rental);

      // expense is a negative number so we just do a Revenue + Expense
      rental.profit = rental.revenue + rental.expense;

      for (var unit in allUnits) {
        if ((unit as RentUnit).building == rental.id.toString()) {
          rental.units.add(unit);
        }
      }
    }
  }

  static cumulateTransactions(Rental rental) {
    for (var t in Transactions.list) {
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
  String building = "";
  String renter = "";
  String note = "";

  RentUnit(id, name) : super(id, name) {
    //
  }
}

class RentUnits {
  static MoneyObjects moneyObjects = MoneyObjects();

  static RentUnit? get(id) {
    return moneyObjects.get(id) as RentUnit?;
  }

  static String getNameFromId(num id) {
    var found = get(id);
    if (found == null) {
      return id.toString();
    }
    return found.name;
  }

  load(rows) async {
    for (var row in rows) {
      var id = num.parse(row["Id"].toString());
      var name = row["Name"].toString();

      var instance = RentUnit(id, name);
      instance.building = row["Building"].toString();
      instance.renter = row["Renter"].toString();
      instance.note = row["Note"].toString();

      moneyObjects.addEntry(instance);
    }
  }

  loadDemoData() {}

  static onAllDataLoaded() {
    for (var item in moneyObjects.getAsList()) {
      var a = item as Rental;
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
