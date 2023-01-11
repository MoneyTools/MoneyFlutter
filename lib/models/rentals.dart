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
  num categoryForTaxes = -1;
  num categoryForInterest = -1;
  num categoryForRepairs = -1;
  num categoryForMaintenance = -1;
  num categoryForManagement = -1;

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
    instance.categoryForTaxes = MoneyEntity.fromRowColumnToNumber(row, "CategoryForTaxes");
    instance.categoryForInterest = MoneyEntity.fromRowColumnToNumber(row, "CategoryForInterest");
    instance.categoryForRepairs = MoneyEntity.fromRowColumnToNumber(row, "CategoryForRepairs");
    instance.categoryForMaintenance = MoneyEntity.fromRowColumnToNumber(row, "CategoryForMaintenance");
    instance.categoryForManagement = MoneyEntity.fromRowColumnToNumber(row, "CategoryForManagement");
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

  load(rows) async {
    for (var row in rows) {
      try {
        Rental instance = Rental.createInstanceFromRow(row);
        moneyObjects.addEntry(instance);
      } catch (error) {
        debugLog(error);
      }
    }
  }

  loadDemoData() {
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

      allUnits.forEach((unit) {
        if (unit.building == rental.id.toString()) {
          rental.units.add(unit);
        }
      });
    }
  }

  static cumulateTransactions(Rental rental) {
    var listOfCategoryIdsToMatch = Categories.getTreeIds(rental.categoryForIncome);

    var listOfCategoryIdsExpenses1 = Categories.getTreeIds(rental.categoryForMaintenance);
    var listOfCategoryIdsExpenses2 = Categories.getTreeIds(rental.categoryForInterest);
    var listOfCategoryIdsExpenses3 = Categories.getTreeIds(rental.categoryForManagement);
    var listOfCategoryIdsExpenses4 = Categories.getTreeIds(rental.categoryForRepairs);
    var listOfCategoryIdsExpenses5 = Categories.getTreeIds(rental.categoryForTaxes);

    var listOfCategoryIdsExpenses = [];
    listOfCategoryIdsExpenses.addAll(listOfCategoryIdsExpenses1);
    listOfCategoryIdsExpenses.addAll(listOfCategoryIdsExpenses2);
    listOfCategoryIdsExpenses.addAll(listOfCategoryIdsExpenses3);
    listOfCategoryIdsExpenses.addAll(listOfCategoryIdsExpenses4);
    listOfCategoryIdsExpenses.addAll(listOfCategoryIdsExpenses5);

    for (var t in Transactions.list) {
      if (listOfCategoryIdsToMatch.contains(t.categoryId)) {
        rental.dateRange.inflate(t.dateTime);
        rental.count++;
        rental.revenue += t.amount;
      } else {
        if (listOfCategoryIdsExpenses.contains(t.categoryId)) {
          rental.dateRange.inflate(t.dateTime);
          rental.count++;
          rental.expense += t.amount;
        }
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
