import 'package:money/helpers/json_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/rental_unit/rental_unit.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/money_objects/money_object.dart';

class RentBuilding extends MoneyObject<RentBuilding> {
  @override
  int get uniqueId => id.value;

  // 0    Id                      INT            0                    1
  DeclareId<RentBuilding> id = DeclareId<RentBuilding>(
    importance: 0,
    valueFromInstance: (final RentBuilding instance) => instance.id.value,
    valueForSerialization: (final RentBuilding instance) => instance.id.value,
  );

  // 1    Name                    nvarchar(255)  1                    0
  DeclareString<RentBuilding> name = DeclareString<RentBuilding>(
    importance: 1,
    name: 'Name',
    serializeName: 'Name',
    valueFromInstance: (final RentBuilding instance) => instance.name.value,
    valueForSerialization: (final RentBuilding instance) => instance.name.value,
  );

  // 2    Address                 nvarchar(255)  0                    0
  DeclareString<RentBuilding> address = DeclareString<RentBuilding>(
    importance: 2,
    name: 'Address',
    serializeName: 'Address',
    valueFromInstance: (final RentBuilding instance) => instance.address.value,
    valueForSerialization: (final RentBuilding instance) => instance.address.value,
  );

  // 3    PurchasedDate           datetime       0                    0
  // 4    PurchasedPrice          money          0                    0
  // 5    LandValue               money          0                    0
  // 6    EstimatedValue          money          0                    0
  // 7    OwnershipName1          nvarchar(255)  0                    0
  // 8    OwnershipName2          nvarchar(255)  0                    0
  // 9    OwnershipPercentage1    money          0                    0
  // 10   OwnershipPercentage2    money          0                    0
  // 11   Note                    nvarchar(255)  0                    0
  // 12   CategoryForTaxes        INT            0                    0
  // 13   CategoryForIncome       INT            0                    0
  // 14   CategoryForInterest     INT            0                    0
  // 15   CategoryForRepairs      INT            0                    0
  // 16   CategoryForMaintenance  INT            0                    0
  // 17   CategoryForManagement   INT            0                    0
  int count = 0;

  /// Revenue
  DeclareDouble<RentBuilding> revenue = DeclareDouble<RentBuilding>(
    importance: 20,
    name: 'Revenue',
    valueFromInstance: (final RentBuilding instance) => instance.revenue.value,
  );

  /// Expenses
  DeclareDouble<RentBuilding> expense = DeclareDouble<RentBuilding>(
    importance: 21,
    name: 'Expenses',
    valueFromInstance: (final RentBuilding instance) => instance.expense.value,
  );

  /// Profit
  DeclareDouble<RentBuilding> profit = DeclareDouble<RentBuilding>(
    importance: 22,
    name: 'Profit',
    valueFromInstance: (final RentBuilding instance) => instance.profit.value,
  );

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

  /*
    SQLite table definition

     0|Id|INT|0||1
     1|Name|nvarchar(255)|1||0
     2|Address|nvarchar(255)|0||0
     3|PurchasedDate|datetime|0||0
     4|PurchasedPrice|money|0||0
     5|LandValue|money|0||0
     6|EstimatedValue|money|0||0
     7|OwnershipName1|nvarchar(255)|0||0
     8|OwnershipName2|nvarchar(255)|0||0
     9|OwnershipPercentage1|money|0||0
    10|OwnershipPercentage2|money|0||0
    11|Note|nvarchar(255)|0||0
    12|CategoryForTaxes|INT|0||0
    13|CategoryForIncome|INT|0||0
    14|CategoryForInterest|INT|0||0
    15|CategoryForRepairs|INT|0||0
    16|CategoryForMaintenance|INT|0||0
    17|CategoryForManagement|INT|0||0
   */
  RentBuilding();

  factory RentBuilding.fromSqlite(final Json row) {
    final RentBuilding instance = RentBuilding();

    instance.id.value = jsonGetInt(row, 'Id');
    instance.name.value = jsonGetString(row, 'Name');
    instance.address.value = jsonGetString(row, 'Address');

    instance.purchasedDate = jsonGetDate(row, 'PurchasedDate', defaultIfNotFound: DateTime.now());
    instance.purchasedPrice = jsonGetDouble(row, 'PurchasedPrice');
    instance.landValue = jsonGetDouble(row, 'LandValue');
    instance.estimatedValue = jsonGetDouble(row, 'EstimatedValue');

    instance.categoryForIncome = jsonGetInt(row, 'CategoryForIncome');
    instance.categoryForIncomeTreeIds = Data().categories.getTreeIds(instance.categoryForIncome);

    instance.categoryForTaxes = jsonGetInt(row, 'CategoryForTaxes');
    instance.categoryForTaxesTreeIds = Data().categories.getTreeIds(instance.categoryForTaxes);

    instance.categoryForInterest = jsonGetInt(row, 'CategoryForInterest');
    instance.categoryForInterestTreeIds = Data().categories.getTreeIds(instance.categoryForInterest);

    instance.categoryForRepairs = jsonGetInt(row, 'CategoryForRepairs');
    instance.categoryForRepairsTreeIds = Data().categories.getTreeIds(instance.categoryForRepairs);

    instance.categoryForMaintenance = jsonGetInt(row, 'CategoryForMaintenance');
    instance.categoryForMaintenanceTreeIds = Data().categories.getTreeIds(instance.categoryForMaintenance);

    instance.categoryForManagement = jsonGetInt(row, 'CategoryForManagement');
    instance.categoryForManagementTreeIds = Data().categories.getTreeIds(instance.categoryForManagement);

    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForTaxesTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForMaintenanceTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForManagementTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForRepairsTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForInterestTreeIds);

    instance.ownershipName1 = jsonGetString(row, 'OwnershipName1');
    instance.ownershipName2 = jsonGetString(row, 'OwnershipName2');
    instance.ownershipPercentage1 = jsonGetDouble(row, 'ownershipPercentage1');
    instance.ownershipPercentage2 = jsonGetDouble(row, 'ownershipPercentage1');
    instance.note = jsonGetString(row, 'Note');

    return instance;
  }
}
