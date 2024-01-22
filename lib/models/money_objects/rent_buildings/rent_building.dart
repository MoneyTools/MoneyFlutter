import 'package:money/helpers/json_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/rental_unit/rental_unit.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/money_objects/money_object.dart';

class RentBuilding extends MoneyObject<RentBuilding> {
  @override
  int get uniqueId => id.value;

  // 0    Id                      INT            0                    1
  FieldId<RentBuilding> id = FieldId<RentBuilding>(
    importance: 0,
    valueFromInstance: (final RentBuilding instance) => instance.id.value,
    valueForSerialization: (final RentBuilding instance) => instance.id.value,
  );

  // 1    Name                    nvarchar(255)  1                    0
  FieldString<RentBuilding> name = FieldString<RentBuilding>(
    importance: 1,
    name: 'Name',
    serializeName: 'Name',
    valueFromInstance: (final RentBuilding instance) => instance.name.value,
    valueForSerialization: (final RentBuilding instance) => instance.name.value,
  );

  // 2    Address                 nvarchar(255)  0                    0
  FieldString<RentBuilding> address = FieldString<RentBuilding>(
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
  FieldAmount<RentBuilding> revenue = FieldAmount<RentBuilding>(
    importance: 20,
    name: 'Revenue',
    valueFromInstance: (final RentBuilding instance) => instance.revenue.value,
  );

  /// Expenses
  FieldAmount<RentBuilding> expense = FieldAmount<RentBuilding>(
    importance: 21,
    name: 'Expenses',
    valueFromInstance: (final RentBuilding instance) => instance.expense.value,
  );

  /// Profit
  FieldAmount<RentBuilding> profit = FieldAmount<RentBuilding>(
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

  factory RentBuilding.fromSqlite(final MyJson row) {
    final RentBuilding instance = RentBuilding();

    instance.id.value = row.getInt('Id');
    instance.name.value = row.getString('Name');
    instance.address.value = row.getString('Address');

    instance.purchasedDate = row.getDate('PurchasedDate', DateTime.now());
    instance.purchasedPrice = row.getDouble('PurchasedPrice');
    instance.landValue = row.getDouble('LandValue');
    instance.estimatedValue = row.getDouble('EstimatedValue');

    instance.categoryForIncome = row.getInt('CategoryForIncome');
    instance.categoryForIncomeTreeIds = Data().categories.getTreeIds(instance.categoryForIncome);

    instance.categoryForTaxes = row.getInt('CategoryForTaxes');
    instance.categoryForTaxesTreeIds = Data().categories.getTreeIds(instance.categoryForTaxes);

    instance.categoryForInterest = row.getInt('CategoryForInterest');
    instance.categoryForInterestTreeIds = Data().categories.getTreeIds(instance.categoryForInterest);

    instance.categoryForRepairs = row.getInt('CategoryForRepairs');
    instance.categoryForRepairsTreeIds = Data().categories.getTreeIds(instance.categoryForRepairs);

    instance.categoryForMaintenance = row.getInt('CategoryForMaintenance');
    instance.categoryForMaintenanceTreeIds = Data().categories.getTreeIds(instance.categoryForMaintenance);

    instance.categoryForManagement = row.getInt('CategoryForManagement');
    instance.categoryForManagementTreeIds = Data().categories.getTreeIds(instance.categoryForManagement);

    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForTaxesTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForMaintenanceTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForManagementTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForRepairsTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForInterestTreeIds);

    instance.ownershipName1 = row.getString('OwnershipName1');
    instance.ownershipName2 = row.getString('OwnershipName2');
    instance.ownershipPercentage1 = row.getDouble('ownershipPercentage1');
    instance.ownershipPercentage2 = row.getDouble('ownershipPercentage1');
    instance.note = row.getString('Note');

    return instance;
  }
}
