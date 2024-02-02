import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/rental_unit/rental_unit.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/widgets/list_view/list_item_card.dart';

class RentBuilding extends MoneyObject<RentBuilding> {
  @override
  int get uniqueId => id.value;

  /// ID
  // 0    Id                      INT            0                    1
  FieldId<RentBuilding> id = FieldId<RentBuilding>(
    importance: 0,
    valueFromInstance: (final RentBuilding instance) => instance.id.value,
    valueForSerialization: (final RentBuilding instance) => instance.id.value,
  );

  /// Name
  // 1    Name                    nvarchar(255)  1                    0
  FieldString<RentBuilding> name = FieldString<RentBuilding>(
    importance: 1,
    name: 'Name',
    serializeName: 'Name',
    valueFromInstance: (final RentBuilding instance) => instance.name.value,
    valueForSerialization: (final RentBuilding instance) => instance.name.value,
  );

  /// Address
  // 2    Address                 nvarchar(255)  0                    0
  FieldString<RentBuilding> address = FieldString<RentBuilding>(
    importance: 2,
    name: 'Address',
    serializeName: 'Address',
    valueFromInstance: (final RentBuilding instance) => instance.address.value,
    valueForSerialization: (final RentBuilding instance) => instance.address.value,
  );

  /// PurchasedDate
  // 3    PurchasedDate           datetime       0                    0
  FieldDate<RentBuilding> purchasedDate = FieldDate<RentBuilding>(
    importance: 2,
    name: 'Purchased Date',
    serializeName: 'PurchasedDate',
    useAsColumn: false,
    valueFromInstance: (final RentBuilding instance) => dateAsIso8601OrDefault(instance.purchasedDate.value),
    valueForSerialization: (final RentBuilding instance) => dateAsIso8601OrDefault(instance.purchasedDate.value),
  );

  /// PurchasedPrice
  // 4    PurchasedPrice          money          0                    0
  FieldAmount<RentBuilding> purchasedPrice = FieldAmount<RentBuilding>(
    importance: 2,
    name: 'Purchased Price',
    serializeName: 'PurchasedPrice',
    useAsColumn: false,
    valueFromInstance: (final RentBuilding instance) => instance.purchasedPrice.value,
    valueForSerialization: (final RentBuilding instance) => instance.purchasedPrice.value,
  );

  /// LandValue
  // 5    LandValue          money          0                    0
  FieldAmount<RentBuilding> landValue = FieldAmount<RentBuilding>(
    importance: 2,
    name: 'LandValue',
    serializeName: 'LandValue',
    valueFromInstance: (final RentBuilding instance) => instance.landValue.value,
    valueForSerialization: (final RentBuilding instance) => instance.landValue.value,
  );

  /// EstimatedValue
  // 6    EstimatedValue          money          0                    0
  FieldAmount<RentBuilding> estimatedValue = FieldAmount<RentBuilding>(
    importance: 2,
    name: 'EstimatedValue',
    serializeName: 'EstimatedValue',
    valueFromInstance: (final RentBuilding instance) => instance.estimatedValue.value,
    valueForSerialization: (final RentBuilding instance) => instance.estimatedValue.value,
  );

  /// OwnershipName1
  // 7    OwnershipName1          money          0                    0
  FieldString<RentBuilding> ownershipName1 = FieldString<RentBuilding>(
    importance: 2,
    name: 'OwnershipName1',
    serializeName: 'OwnershipName1',
    useAsColumn: false,
    valueFromInstance: (final RentBuilding instance) => instance.ownershipName1.value,
    valueForSerialization: (final RentBuilding instance) => instance.ownershipName1.value,
  );

  /// OwnershipName2
  // 8    OwnershipName2          money          0                    0
  FieldString<RentBuilding> ownershipName2 = FieldString<RentBuilding>(
    importance: 2,
    name: 'OwnershipName2',
    serializeName: 'OwnershipName2',
    useAsColumn: false,
    valueFromInstance: (final RentBuilding instance) => instance.ownershipName2.value,
    valueForSerialization: (final RentBuilding instance) => instance.ownershipName2.value,
  );

  /// OwnershipPercentage1
  // 9    OwnershipPercentage1          money          0                    0
  FieldDouble<RentBuilding> ownershipPercentage1 = FieldDouble<RentBuilding>(
    importance: 2,
    name: 'OwnershipPercentage1',
    serializeName: 'OwnershipPercentage1',
    useAsColumn: false,
    valueFromInstance: (final RentBuilding instance) => instance.ownershipPercentage1.value,
    valueForSerialization: (final RentBuilding instance) => instance.ownershipPercentage1.value,
  );

  /// OwnershipPercentage2
  // 10    OwnershipPercentage2          money          0                    0
  FieldDouble<RentBuilding> ownershipPercentage2 = FieldDouble<RentBuilding>(
    importance: 2,
    name: 'OwnershipPercentage2',
    serializeName: 'OwnershipPercentage2',
    useAsColumn: false,
    valueFromInstance: (final RentBuilding instance) => instance.ownershipPercentage2.value,
    valueForSerialization: (final RentBuilding instance) => instance.ownershipPercentage2.value,
  );

  /// Note
  // 11    Note          money          0                    0
  FieldString<RentBuilding> note = FieldString<RentBuilding>(
    importance: 2,
    name: 'Note',
    serializeName: 'Note',
    useAsColumn: false,
    valueFromInstance: (final RentBuilding instance) => instance.note.value,
    valueForSerialization: (final RentBuilding instance) => instance.note.value,
  );

  /// CategoryForTaxes
  // 12    CategoryForTaxes          money          0                    0
  FieldInt<RentBuilding> categoryForTaxes = FieldInt<RentBuilding>(
    importance: 2,
    name: 'CategoryForTaxes',
    serializeName: 'CategoryForTaxes',
    useAsColumn: false,
    valueFromInstance: (final RentBuilding instance) => instance.categoryForTaxes.value,
    valueForSerialization: (final RentBuilding instance) => instance.categoryForTaxes.value,
  );

  /// CategoryForIncome
  // 13    CategoryForIncome          money          0                    0
  FieldInt<RentBuilding> categoryForIncome = FieldInt<RentBuilding>(
    importance: 2,
    name: 'CategoryForIncome',
    serializeName: 'CategoryForIncome',
    useAsColumn: false,
    valueFromInstance: (final RentBuilding instance) => instance.categoryForIncome.value,
    valueForSerialization: (final RentBuilding instance) => instance.categoryForIncome.value,
  );

  /// CategoryForInterest
  // 14    CategoryForInterest          money          0                    0
  FieldInt<RentBuilding> categoryForInterest = FieldInt<RentBuilding>(
    importance: 2,
    name: 'CategoryForInterest',
    serializeName: 'CategoryForInterest',
    useAsColumn: false,
    valueFromInstance: (final RentBuilding instance) => instance.categoryForInterest.value,
    valueForSerialization: (final RentBuilding instance) => instance.categoryForInterest.value,
  );

  /// CategoryForRepairs
  // 15    CategoryForRepairs          money          0                    0
  FieldInt<RentBuilding> categoryForRepairs = FieldInt<RentBuilding>(
    importance: 2,
    name: 'CategoryForRepairs',
    serializeName: 'CategoryForRepairs',
    useAsColumn: false,
    valueFromInstance: (final RentBuilding instance) => instance.categoryForRepairs.value,
    valueForSerialization: (final RentBuilding instance) => instance.categoryForRepairs.value,
  );

  /// CategoryForMaintenance
  // 16    CategoryForMaintenance          money          0                    0
  FieldInt<RentBuilding> categoryForMaintenance = FieldInt<RentBuilding>(
    importance: 2,
    name: 'CategoryForMaintenance',
    serializeName: 'CategoryForMaintenance',
    useAsColumn: false,
    valueFromInstance: (final RentBuilding instance) => instance.categoryForMaintenance.value,
    valueForSerialization: (final RentBuilding instance) => instance.categoryForMaintenance.value,
  );

  /// CategoryForManagement
  // 17    CategoryForManagement          money          0                    0
  FieldInt<RentBuilding> categoryForManagement = FieldInt<RentBuilding>(
    importance: 2,
    name: 'CategoryForManagement',
    serializeName: 'CategoryForManagement',
    useAsColumn: false,
    valueFromInstance: (final RentBuilding instance) => instance.categoryForManagement.value,
    valueForSerialization: (final RentBuilding instance) => instance.categoryForManagement.value,
  );

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

  List<int> categoryForIncomeTreeIds = <int>[];
  List<int> categoryForTaxesTreeIds = <int>[];
  List<int> categoryForInterestTreeIds = <int>[];
  List<int> categoryForRepairsTreeIds = <int>[];
  List<int> categoryForMaintenanceTreeIds = <int>[];
  List<int> categoryForManagementTreeIds = <int>[];

  List<int> listOfCategoryIdsExpenses = <int>[];

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
  RentBuilding() {
    buildListWidgetForSmallScreen = () => MyListItemAsCard(
          leftTopAsString: name.value,
          leftBottomAsString: address.value,
          rightTopAsString: Currency.getCurrencyText(profit.value),
        );
  }

  factory RentBuilding.fromJson(final MyJson row) {
    final RentBuilding instance = RentBuilding();

    instance.id.value = row.getInt('Id');
    instance.name.value = row.getString('Name');
    instance.address.value = row.getString('Address');
    instance.purchasedDate.value = row.getDate('PurchasedDate', DateTime.now());
    instance.purchasedPrice.value = row.getDouble('PurchasedPrice');
    instance.landValue.value = row.getDouble('LandValue');
    instance.estimatedValue.value = row.getDouble('EstimatedValue');
    instance.ownershipName1.value = row.getString('OwnershipName1');
    instance.ownershipName2.value = row.getString('OwnershipName2');
    instance.ownershipPercentage1.value = row.getDouble('ownershipPercentage1');
    instance.ownershipPercentage2.value = row.getDouble('ownershipPercentage1');

    instance.categoryForIncome.value = row.getInt('CategoryForIncome');
    instance.categoryForIncomeTreeIds = Data().categories.getTreeIds(instance.categoryForIncome.value);

    instance.categoryForTaxes.value = row.getInt('CategoryForTaxes');
    instance.categoryForTaxesTreeIds = Data().categories.getTreeIds(instance.categoryForTaxes.value);

    instance.categoryForInterest.value = row.getInt('CategoryForInterest');
    instance.categoryForInterestTreeIds = Data().categories.getTreeIds(instance.categoryForInterest.value);

    instance.categoryForRepairs.value = row.getInt('CategoryForRepairs');
    instance.categoryForRepairsTreeIds = Data().categories.getTreeIds(instance.categoryForRepairs.value);

    instance.categoryForMaintenance.value = row.getInt('CategoryForMaintenance');
    instance.categoryForMaintenanceTreeIds = Data().categories.getTreeIds(instance.categoryForMaintenance.value);

    instance.categoryForManagement.value = row.getInt('CategoryForManagement');
    instance.categoryForManagementTreeIds = Data().categories.getTreeIds(instance.categoryForManagement.value);

    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForTaxesTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForMaintenanceTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForManagementTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForRepairsTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForInterestTreeIds);

    instance.note.value = row.getString('Note');

    return instance;
  }
}
